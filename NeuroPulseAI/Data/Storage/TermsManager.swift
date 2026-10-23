//
//  TermsManager.swift
//  NeuroPulseAI
//
//  Manages versioned Terms & Conditions acceptance on a strictly per-account basis.
//  Guarantees that one user's acceptance never leaks into or satisfies another user's account.
//

import Foundation
import Combine

@MainActor
public final class TermsManager: ObservableObject {
    public static let shared = TermsManager()
    
    /// Global current version of the Terms & Conditions.
    public static let currentTermsVersion: String = "2026-10-24"
    
    @Published public private(set) var hasAcceptedCurrentTerms: Bool = false
    @Published public private(set) var acceptedVersion: String? = nil
    @Published public private(set) var acceptedDate: Date? = nil
    
    public var isAccepted: Bool {
        return hasAcceptedCurrentTerms
    }
    
    public private(set) var activeAccountID: String? = nil
    
    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    private func versionKey(for accountID: String?) -> String {
        let id = accountID ?? "local"
        return "neuropulse_terms_version_\(id)"
    }
    
    private func dateKey(for accountID: String?) -> String {
        let id = accountID ?? "local"
        return "neuropulse_terms_date_\(id)"
    }
    
    /// Checks whether the specified account has accepted the current Terms & Conditions version.
    public func hasAcceptedCurrentTerms(accountID: String?) -> Bool {
        let key = versionKey(for: accountID)
        guard let savedVersion = userDefaults.string(forKey: key) else {
            return false
        }
        return savedVersion == Self.currentTermsVersion
    }
    
    /// Returns the accepted version for a specific account without switching active state.
    public func acceptedVersion(for accountID: String?) -> String? {
        let key = versionKey(for: accountID)
        return userDefaults.string(forKey: key)
    }
    
    /// Loads the Terms acceptance state for the specified account into in-memory published properties.
    public func loadForAccount(accountID: String?) {
        self.activeAccountID = accountID
        let vKey = versionKey(for: accountID)
        let dKey = dateKey(for: accountID)
        
        if let ver = userDefaults.string(forKey: vKey) {
            acceptedVersion = ver
            hasAcceptedCurrentTerms = (ver == Self.currentTermsVersion)
        } else {
            acceptedVersion = nil
            hasAcceptedCurrentTerms = false
        }
        
        if let timestamp = userDefaults.object(forKey: dKey) as? Double {
            acceptedDate = Date(timeIntervalSince1970: timestamp)
        } else {
            acceptedDate = nil
        }
    }
    
    /// Records acceptance of the current Terms version for the specified account.
    public func acceptTerms(accountID: String?) {
        let targetAccount = accountID ?? activeAccountID
        let vKey = versionKey(for: targetAccount)
        let dKey = dateKey(for: targetAccount)
        let now = Date()
        
        userDefaults.set(Self.currentTermsVersion, forKey: vKey)
        userDefaults.set(now.timeIntervalSince1970, forKey: dKey)
        
        if targetAccount == activeAccountID {
            acceptedVersion = Self.currentTermsVersion
            acceptedDate = now
            hasAcceptedCurrentTerms = true
        }
    }
    
    /// Resets in-memory state on sign out so no previous user's acceptance remains visible.
    public func resetForSignOut() {
        activeAccountID = nil
        hasAcceptedCurrentTerms = false
        acceptedVersion = nil
        acceptedDate = nil
    }
    
    /// Test helper to reset stored acceptance for testing.
    public func clearForTesting(accountID: String?) {
        userDefaults.removeObject(forKey: versionKey(for: accountID))
        userDefaults.removeObject(forKey: dateKey(for: accountID))
        if accountID == activeAccountID {
            resetForSignOut()
        }
    }
}
