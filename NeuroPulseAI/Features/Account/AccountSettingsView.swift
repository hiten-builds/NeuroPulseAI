//
//  AccountSettingsView.swift
//  NeuroPulseAI
//
//  Account management, purpose-specific consent controls, remote data deletion,
//  and session sign-out controls.
//

import SwiftUI

public struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var consentManager = ConsentManager.shared
    @ObservedObject private var termsManager = TermsManager.shared
    @ObservedObject private var syncService = SyncService.shared
    
    @State private var showingAuthSheet = false
    @State private var showingDeleteDataAlert = false
    @State private var showingConsentSheet = false
    @State private var showingTermsSheet = false
    @State private var actionFeedbackMessage: String? = nil
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.large) {
                // MARK: - Account Status Section
                accountStatusCard
                
                // MARK: - Terms & Conditions Section
                termsStatusCard
                
                // MARK: - Personalization Consent Section
                consentStatusCard
                
                // MARK: - Remote Data Management (Authenticated Users)
                if authManager.currentMode == .authenticated {
                    remoteDataCard
                }
                
                // MARK: - Navigation / Sign Out
                actionsSection
                
                // MARK: - Feedback Banner
                if let message = actionFeedbackMessage {
                    Text(message)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)
                        .padding(DesignTokens.Spacing.small)
                        .frame(maxWidth: .infinity)
                        .brutalRow(cornerRadius: 12, fill: Color.NeoBrutal.mint)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.vertical, DesignTokens.Spacing.large)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Account & Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAuthSheet) {
            AuthenticationView()
        }
        .sheet(isPresented: $showingTermsSheet) {
            NavigationStack {
                TermsAndConditionsView(
                    onAccept: {
                        showingTermsSheet = false
                    },
                    onDecline: {
                        showingTermsSheet = false
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") {
                            showingTermsSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingConsentSheet) {
            NavigationStack {
                PersonalizationConsentView(onCompletion: {
                    showingConsentSheet = false
                })
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") {
                            showingConsentSheet = false
                        }
                    }
                }
            }
        }
        .alert("Delete Remote Activity Data?", isPresented: $showingDeleteDataAlert) {
            Button("Delete Remote Data", role: .destructive) {
                deleteRemoteData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all uploaded motor assessments and wellness records from the NeuroPulseAI cloud server and withdraw consent. Your local on-device records will remain intact.")
        }
    }
    
    // MARK: - Subviews
    
    private var accountStatusCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                BrutalIconTile(iconName: authManager.currentMode == .authenticated ? "person.fill.checkmark" : "iphone", size: 40, iconSize: 18, bg: Color.NeoBrutal.lavender)
                Text("Account Status")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)
                Spacer()
                statusPill
            }
            
            Divider()
            
            if authManager.currentMode == .authenticated, let user = authManager.currentUser {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email: \(user.email)")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)
                    Text("Account ID: \(user.id.prefix(8))...")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)
                }
            } else {
                Text("Operating in Local-Only Mode. All activity records and metrics are retained strictly on this device.")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.mutedText)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .brutalCard(cornerRadius: 20)
    }
    
    private var statusPill: some View {
        let isAuth = authManager.currentMode == .authenticated
        return BrutalBadge(isAuth ? "Authenticated" : "Local Only", style: isAuth ? .inProgress : .pending)
    }
    
    private var termsStatusCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                BrutalIconTile(iconName: "doc.text.magnifyingglass", size: 40, iconSize: 18, bg: Color.NeoBrutal.mint)
                Text("Terms & Conditions")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)
                Spacer()
                termsStatusBadge
            }
            
            Divider()
            
            if let version = termsManager.acceptedVersion {
                Text("Accepted Version: \(version)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)
                if let date = termsManager.acceptedDate {
                    Text("Accepted on: \(date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)
                }
            } else {
                Text("Current Version: \(TermsManager.currentTermsVersion) (Explicit acceptance required)")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.mutedText)
            }
            
            Button {
                showingTermsSheet = true
            } label: {
                Text("Review Terms & Conditions")
            }
            .buttonStyle(BrutalCompactButtonStyle(fill: Color.NeoBrutal.lavender))
            .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .brutalCard(cornerRadius: 20)
    }
    
    private var termsStatusBadge: some View {
        let isAccepted = termsManager.isAccepted
        let label = isAccepted ? "Accepted" : "Pending"
        return BrutalBadge(label, style: isAccepted ? .inProgress : .pending)
    }
    
    private var consentStatusCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                BrutalIconTile(iconName: "hand.raised.square.on.square.fill", size: 40, iconSize: 18, bg: Color.NeoBrutal.peach)
                Text("Data-Sharing Consent")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)
                Spacer()
                consentDecisionBadge
            }
            
            Divider()
            
            Text("Purpose: Personalization of recommendations based on authorized motor and wellness trends (v\(consentManager.consentVersion)).")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)
            
            HStack(spacing: DesignTokens.Spacing.small) {
                if consentManager.isPersonalizationConsented {
                    Button(role: .destructive) {
                        withdrawConsent()
                    } label: {
                        Text("Withdraw Consent")
                    }
                    .buttonStyle(BrutalCompactButtonStyle(fill: Color.NeoBrutal.badgePendingBg))
                } else {
                    Button {
                        showingConsentSheet = true
                    } label: {
                        Text("Review Consent Options")
                    }
                    .buttonStyle(BrutalCompactButtonStyle(fill: Color.NeoBrutal.lavender))
                }
            }
            .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .brutalCard(cornerRadius: 20)
    }
    
    private var consentDecisionBadge: some View {
        switch consentManager.decision {
        case .granted:
            return BrutalBadge("Active", style: .inProgress)
        case .declined:
            return BrutalBadge("Declined", style: .pending)
        case .withdrawn:
            return BrutalBadge("Withdrawn", style: .pending)
        case .undecided:
            return BrutalBadge("Not Decided", style: .pending)
        }
    }
    
    private var remoteDataCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                BrutalIconTile(iconName: "trash.circle", size: 40, iconSize: 18, bg: Color.NeoBrutal.badgePendingBg, iconColor: Color.NeoBrutal.alertRed)
                Text("Cloud Data Management")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)
            }
            
            Text("Request permanent deletion of all assessment and wellness records synchronized to the backend. Local records on this device will NOT be deleted.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)
            
            Button(role: .destructive) {
                showingDeleteDataAlert = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                    Text("Delete Remote Data")
                }
            }
            .buttonStyle(BrutalCompactButtonStyle(fill: Color.NeoBrutal.badgePendingBg))
            .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .brutalCard(cornerRadius: 20)
    }
    
    private var actionsSection: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            if authManager.currentMode == .authenticated {
                Button(role: .destructive) {
                    authManager.signOut()
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Sign Out")
                    }
                }
                .buttonStyle(BrutalDestructiveButtonStyle())
            } else {
                Button {
                    showingAuthSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "person.badge.key.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Sign In or Register")
                    }
                }
                .buttonStyle(BrutalButtonStyle(fill: Color.NeoBrutal.lavender))
            }
            
            Button {
                authManager.returnToWelcome()
                dismiss()
            } label: {
                Text("Return to Welcome Screen")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.mutedText)
            }
            .padding(.top, 4)
        }
    }
    
    private func withdrawConsent() {
        Task {
            let token = authManager.authToken
            _ = await consentManager.withdrawConsent(authToken: token)
            actionFeedbackMessage = "Consent has been withdrawn. Future uploads are blocked."
        }
    }
    
    private func deleteRemoteData() {
        Task {
            let success = await syncService.deleteRemoteData()
            if success {
                actionFeedbackMessage = "Remote activity records successfully deleted from the server."
            } else {
                actionFeedbackMessage = syncService.lastSyncError ?? "Failed to delete remote records."
            }
        }
    }
}
