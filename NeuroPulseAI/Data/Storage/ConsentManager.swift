//
//  ConsentManager.swift
//  NeuroPulseAI
//
//  Manages purpose-specific, versioned data-sharing consent on a strictly per-account basis.
//  Enforces the rule that account creation and data-sharing permission are strictly separate,
//  and guarantees that one user's consent decision never leaks into another account.
//

import Foundation
import Combine

public enum ConsentDecision: String, Codable, Sendable {
    case undecided = "undecided"
    case granted = "granted"
    case declined = "declined"
    case withdrawn = "withdrawn"
}

@MainActor
public final class ConsentManager: ObservableObject {
    public static let shared = ConsentManager()
    
    @Published public private(set) var decision: ConsentDecision = .undecided
    @Published public private(set) var consentVersion: String = "1.0"
    @Published public private(set) var lastDecisionDate: Date? = nil
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    public private(set) var activeAccountID: String? = nil
    
    private let apiClient: APIClientProtocol
    private let userDefaults: UserDefaults
    
    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.apiClient = apiClient
        self.userDefaults = userDefaults
    }
    
    private func decisionKey(for accountID: String?) -> String {
        let id = accountID ?? "local"
        return "neuropulse_consent_decision_\(id)"
    }
    
    private func versionKey(for accountID: String?) -> String {
        let id = accountID ?? "local"
        return "neuropulse_consent_version_\(id)"
    }
    
    private func dateKey(for accountID: String?) -> String {
        let id = accountID ?? "local"
        return "neuropulse_consent_date_\(id)"
    }
    
    /// Loads the stored consent decision for the specified account (or local guest).
    public func loadForAccount(accountID: String?) {
        self.activeAccountID = accountID
        let dKey = decisionKey(for: accountID)
        let vKey = versionKey(for: accountID)
        let tKey = dateKey(for: accountID)
        
        if let raw = userDefaults.string(forKey: dKey),
           let savedDecision = ConsentDecision(rawValue: raw) {
            decision = savedDecision
        } else {
            decision = .undecided
        }
        
        if let ver = userDefaults.string(forKey: vKey) {
            consentVersion = ver
        } else {
            consentVersion = "1.0"
        }
        
        if let timeInterval = userDefaults.object(forKey: tKey) as? Double {
            lastDecisionDate = Date(timeIntervalSince1970: timeInterval)
        } else {
            lastDecisionDate = nil
        }
    }
    
    /// Query the consent decision for a specific account without switching active state.
    public func decision(for accountID: String?) -> ConsentDecision {
        let dKey = decisionKey(for: accountID)
        guard let raw = userDefaults.string(forKey: dKey),
              let dec = ConsentDecision(rawValue: raw) else {
            return .undecided
        }
        return dec
    }
    
    public var isPersonalizationConsented: Bool {
        return decision == .granted
    }
    
    public var hasMadeDecision: Bool {
        return decision != .undecided
    }
    
    /// Query whether a decision has been made for a specific account without switching active state.
    public func hasMadeDecision(for accountID: String?) -> Bool {
        let dec = decision(for: accountID)
        return dec != .undecided
    }
    
    public func grantConsent(authToken: String?, accountID: String? = nil) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let targetAccount = accountID ?? activeAccountID
        let now = Date()
        
        userDefaults.set(ConsentDecision.granted.rawValue, forKey: decisionKey(for: targetAccount))
        userDefaults.set("1.0", forKey: versionKey(for: targetAccount))
        userDefaults.set(now.timeIntervalSince1970, forKey: dateKey(for: targetAccount))
        
        if targetAccount == activeAccountID {
            decision = .granted
            consentVersion = "1.0"
            lastDecisionDate = now
        }
        
        if let token = authToken, !token.isEmpty {
            do {
                _ = try await apiClient.setConsent(
                    token: token,
                    request: ConsentDecisionRequestDTO(decision: "granted", version: "1.0", purpose: "personalization")
                )
                isLoading = false
                return true
            } catch {
                errorMessage = "Saved locally. Server synchronization: \(error.localizedDescription)"
                isLoading = false
                return true
            }
        }
        
        isLoading = false
        return true
    }
    
    public func declineConsent(authToken: String?, accountID: String? = nil) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let targetAccount = accountID ?? activeAccountID
        let now = Date()
        
        userDefaults.set(ConsentDecision.declined.rawValue, forKey: decisionKey(for: targetAccount))
        userDefaults.set("1.0", forKey: versionKey(for: targetAccount))
        userDefaults.set(now.timeIntervalSince1970, forKey: dateKey(for: targetAccount))
        
        if targetAccount == activeAccountID {
            decision = .declined
            consentVersion = "1.0"
            lastDecisionDate = now
        }
        
        if let token = authToken, !token.isEmpty {
            do {
                _ = try await apiClient.setConsent(
                    token: token,
                    request: ConsentDecisionRequestDTO(decision: "declined", version: "1.0", purpose: "personalization")
                )
            } catch {
                // Stays declined locally regardless
            }
        }
        
        isLoading = false
        return true
    }
    
    public func withdrawConsent(authToken: String?, accountID: String? = nil) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let targetAccount = accountID ?? activeAccountID
        let now = Date()
        
        userDefaults.set(ConsentDecision.withdrawn.rawValue, forKey: decisionKey(for: targetAccount))
        userDefaults.set(now.timeIntervalSince1970, forKey: dateKey(for: targetAccount))
        
        if targetAccount == activeAccountID {
            decision = .withdrawn
            lastDecisionDate = now
        }
        
        if let token = authToken, !token.isEmpty {
            do {
                _ = try await apiClient.withdrawConsent(token: token)
            } catch {
                errorMessage = "Consent withdrawn locally. Server update: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
        return true
    }
    
    public func fetchRemoteConsent(authToken: String, accountID: String? = nil) async {
        guard !authToken.isEmpty else { return }
        let targetAccount = accountID ?? activeAccountID
        do {
            let remote = try await apiClient.getConsent(token: authToken)
            let fetchedDecision: ConsentDecision
            if remote.currentStatus == "active" && remote.decision == "granted" {
                fetchedDecision = .granted
            } else if remote.currentStatus == "withdrawn" {
                fetchedDecision = .withdrawn
            } else {
                fetchedDecision = .declined
            }
            
            userDefaults.set(fetchedDecision.rawValue, forKey: decisionKey(for: targetAccount))
            userDefaults.set(remote.version, forKey: versionKey(for: targetAccount))
            
            if targetAccount == activeAccountID {
                decision = fetchedDecision
                consentVersion = remote.version
            }
        } catch {
            // Keep existing local state on network error
        }
    }
    
    /// Resets in-memory state on sign out so no previous user's consent remains visible.
    public func resetForSignOut() {
        activeAccountID = nil
        decision = .undecided
        lastDecisionDate = nil
        errorMessage = nil
    }
    
    public func resetForTesting(accountID: String? = nil) {
        let target = accountID ?? activeAccountID
        userDefaults.removeObject(forKey: decisionKey(for: target))
        userDefaults.removeObject(forKey: versionKey(for: target))
        userDefaults.removeObject(forKey: dateKey(for: target))
        if target == activeAccountID {
            resetForSignOut()
        }
    }
}
