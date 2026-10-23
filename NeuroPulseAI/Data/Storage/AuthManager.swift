//
//  AuthManager.swift
//  NeuroPulseAI
//
//  Manages user authentication lifecycle, operating modes (Welcome, Local-Only, Authenticated),
//  onboarding checkpoint state machine (Terms & Conditions, Data-Sharing Consent),
//  secure token storage via KeychainHelper, and session restoration.
//

import Foundation
import Combine

public enum AuthMode: String, Codable, Sendable {
    case welcome = "welcome"
    case localOnly = "local_only"
    case authenticated = "authenticated"
}

public enum AppFlowState: String, Codable, Sendable {
    case welcome = "welcome"
    case localOnly = "local_only"
    case termsRequired = "terms_required"
    case dataSharingConsentRequired = "consent_required"
    case ready = "ready"
}

@MainActor
public final class AuthManager: ObservableObject {
    public static let shared = AuthManager()
    
    @Published public private(set) var currentMode: AuthMode = .welcome
    @Published public private(set) var flowState: AppFlowState = .welcome
    @Published public private(set) var currentUser: UserDTO? = nil
    @Published public var isAuthenticating: Bool = false
    @Published public var authError: String? = nil
    
    private let apiClient: APIClientProtocol
    private let keychain: KeychainHelper
    private let userDefaults: UserDefaults
    private let termsManager: TermsManager
    private let consentManager: ConsentManager
    
    private let modeKey = "neuropulse_auth_mode"
    private let userCacheKey = "neuropulse_cached_user"
    private let tokenKey = "auth_token"
    
    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        keychain: KeychainHelper = KeychainHelper.shared,
        userDefaults: UserDefaults = .standard,
        termsManager: TermsManager = .shared,
        consentManager: ConsentManager = .shared
    ) {
        self.apiClient = apiClient
        self.keychain = keychain
        self.userDefaults = userDefaults
        self.termsManager = termsManager
        self.consentManager = consentManager
        restoreState()
    }
    
    private func restoreState() {
        if let savedModeRaw = userDefaults.string(forKey: modeKey),
           let savedMode = AuthMode(rawValue: savedModeRaw) {
            if savedMode == .authenticated {
                if let token = keychain.readString(key: tokenKey), !token.isEmpty {
                    currentMode = .authenticated
                    if let userData = userDefaults.data(forKey: userCacheKey),
                       let user = try? JSONDecoder().decode(UserDTO.self, from: userData) {
                        currentUser = user
                        MotorSessionStore.shared.reload(for: user.id)
                        WellnessSessionStore.shared.reload(for: user.id)
                        consentManager.loadForAccount(accountID: user.id)
                        termsManager.loadForAccount(accountID: user.id)
                        evaluateOnboardingRequirements()
                        return
                    }
                }
                currentMode = .welcome
                flowState = .welcome
                MotorSessionStore.shared.reload(for: nil)
                WellnessSessionStore.shared.reload(for: nil)
                consentManager.loadForAccount(accountID: nil)
                termsManager.loadForAccount(accountID: nil)
            } else if savedMode == .localOnly {
                currentMode = .localOnly
                flowState = .localOnly
                MotorSessionStore.shared.reload(for: nil)
                WellnessSessionStore.shared.reload(for: nil)
                consentManager.loadForAccount(accountID: nil)
                termsManager.loadForAccount(accountID: nil)
            } else {
                currentMode = .welcome
                flowState = .welcome
                MotorSessionStore.shared.reload(for: nil)
                WellnessSessionStore.shared.reload(for: nil)
                consentManager.loadForAccount(accountID: nil)
                termsManager.loadForAccount(accountID: nil)
            }
        } else {
            currentMode = .welcome
            flowState = .welcome
            MotorSessionStore.shared.reload(for: nil)
            WellnessSessionStore.shared.reload(for: nil)
            consentManager.loadForAccount(accountID: nil)
            termsManager.loadForAccount(accountID: nil)
        }
    }
    
    /// Evaluates the mandatory onboarding requirements for the currently authenticated account.
    /// Guarantees that authentication alone does not grant access to the main application.
    public func evaluateOnboardingRequirements() {
        guard currentMode == .authenticated, let user = currentUser else {
            if currentMode == .localOnly {
                flowState = .localOnly
            } else {
                flowState = .welcome
            }
            return
        }
        
        // 1. Mandatory Terms & Conditions Check
        if !termsManager.hasAcceptedCurrentTerms(accountID: user.id) {
            flowState = .termsRequired
            return
        }
        
        // 2. Mandatory Data-Sharing Consent Check (tri-state: must not be undecided)
        if !consentManager.hasMadeDecision(for: user.id) {
            flowState = .dataSharingConsentRequired
            return
        }
        
        // 3. All onboarding checkpoints satisfied
        flowState = .ready
    }
    
    public func continueLocally() {
        currentMode = .localOnly
        flowState = .localOnly
        userDefaults.set(AuthMode.localOnly.rawValue, forKey: modeKey)
        authError = nil
        MotorSessionStore.shared.reload(for: nil)
        WellnessSessionStore.shared.reload(for: nil)
        consentManager.loadForAccount(accountID: nil)
        termsManager.loadForAccount(accountID: nil)
    }
    
    public func register(email: String, password: String) async -> Bool {
        guard isValidEmail(email) else {
            authError = "Please enter a valid email address."
            return false
        }
        guard password.count >= 8 else {
            authError = "Password must be at least 8 characters long."
            return false
        }
        
        isAuthenticating = true
        authError = nil
        
        do {
            let response = try await apiClient.register(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            keychain.saveString(key: tokenKey, value: response.accessToken)
            currentUser = response.user
            if let encoded = try? JSONEncoder().encode(response.user) {
                userDefaults.set(encoded, forKey: userCacheKey)
            }
            currentMode = .authenticated
            userDefaults.set(AuthMode.authenticated.rawValue, forKey: modeKey)
            
            // Scope store, consent, and terms state to newly registered user
            MotorSessionStore.shared.reload(for: response.user.id)
            WellnessSessionStore.shared.reload(for: response.user.id)
            consentManager.loadForAccount(accountID: response.user.id)
            termsManager.loadForAccount(accountID: response.user.id)
            
            // Block until requirements are satisfied
            evaluateOnboardingRequirements()
            
            isAuthenticating = false
            return true
        } catch {
            authError = error.localizedDescription
            isAuthenticating = false
            return false
        }
    }
    
    public func signIn(email: String, password: String) async -> Bool {
        guard isValidEmail(email) else {
            authError = "Please enter a valid email address."
            return false
        }
        guard !password.isEmpty else {
            authError = "Password cannot be empty."
            return false
        }
        
        isAuthenticating = true
        authError = nil
        
        do {
            let response = try await apiClient.login(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            keychain.saveString(key: tokenKey, value: response.accessToken)
            currentUser = response.user
            if let encoded = try? JSONEncoder().encode(response.user) {
                userDefaults.set(encoded, forKey: userCacheKey)
            }
            currentMode = .authenticated
            userDefaults.set(AuthMode.authenticated.rawValue, forKey: modeKey)
            
            // Scope store, consent, and terms state to newly signed-in user
            MotorSessionStore.shared.reload(for: response.user.id)
            WellnessSessionStore.shared.reload(for: response.user.id)
            consentManager.loadForAccount(accountID: response.user.id)
            termsManager.loadForAccount(accountID: response.user.id)
            
            // Block until requirements are satisfied
            evaluateOnboardingRequirements()
            
            isAuthenticating = false
            return true
        } catch {
            authError = error.localizedDescription
            isAuthenticating = false
            return false
        }
    }
    
    /// Atomically persists Terms acceptance for the authenticated account and advances the state machine.
    public func acceptTermsAndAdvance() {
        guard let accountID = currentUser?.id else { return }
        termsManager.acceptTerms(accountID: accountID)
        guard termsManager.hasAcceptedCurrentTerms(accountID: accountID) else { return }
        evaluateOnboardingRequirements()
    }
    
    /// Atomically persists Data Sharing Consent decision for the authenticated account and advances the state machine.
    public func recordConsentDecisionAndAdvance(granted: Bool) async -> Bool {
        guard let accountID = currentUser?.id else { return false }
        let success: Bool
        if granted {
            success = await consentManager.grantConsent(authToken: authToken, accountID: accountID)
        } else {
            success = await consentManager.declineConsent(authToken: authToken, accountID: accountID)
        }
        guard consentManager.hasMadeDecision(for: accountID) else { return false }
        evaluateOnboardingRequirements()
        return success
    }
    
    public func signOut() {
        keychain.delete(key: tokenKey)
        currentUser = nil
        userDefaults.removeObject(forKey: userCacheKey)
        currentMode = .welcome
        flowState = .welcome
        userDefaults.set(AuthMode.welcome.rawValue, forKey: modeKey)
        authError = nil
        
        // Reset in-memory account-specific state safely without destroying persisted data
        MotorSessionStore.shared.reload(for: nil)
        WellnessSessionStore.shared.reload(for: nil)
        consentManager.resetForSignOut()
        termsManager.resetForSignOut()
        SyncService.shared.clearSyncCache()
        RecommendationService.shared.clearOnSignOut()
    }
    
    public func returnToWelcome() {
        currentMode = .welcome
        flowState = .welcome
        userDefaults.set(AuthMode.welcome.rawValue, forKey: modeKey)
    }
    
    public var authToken: String? {
        return keychain.readString(key: tokenKey)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.utf16.count))
        return matches?.first?.url?.scheme == "mailto" && trimmed.contains("@") && trimmed.contains(".")
    }
}
