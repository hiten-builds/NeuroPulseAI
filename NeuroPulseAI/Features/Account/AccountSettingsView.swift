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
                        .font(.caption)
                        .foregroundStyle(Color.NeuroPulse.brandTeal)
                        .padding(DesignTokens.Spacing.small)
                        .frame(maxWidth: .infinity)
                        .background(Color.NeuroPulse.brandTeal.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.vertical, DesignTokens.Spacing.large)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
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
                Image(systemName: authManager.currentMode == .authenticated ? "person.fill.checkmark" : "iphone")
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                Text("Account Status")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                statusPill
            }
            
            Divider()
            
            if authManager.currentMode == .authenticated, let user = authManager.currentUser {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email: \(user.email)")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text("Account ID: \(user.id.prefix(8))...")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Operating in Local-Only Mode. All activity records and metrics are retained strictly on this device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(DesignTokens.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
    }
    
    private var statusPill: some View {
        let isAuth = authManager.currentMode == .authenticated
        return Text(isAuth ? "Authenticated" : "Local Only")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(isAuth ? Color.NeuroPulse.brandTeal : Color.NeuroPulse.motorPrimary)
            .padding(.horizontal, DesignTokens.Spacing.small)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill((isAuth ? Color.NeuroPulse.brandTeal : Color.NeuroPulse.motorPrimary).opacity(0.12))
            )
    }
    
    private var termsStatusCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                Text("Terms & Conditions")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                termsStatusBadge
            }
            
            Divider()
            
            if let version = termsManager.acceptedVersion {
                Text("Accepted Version: \(version)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                if let date = termsManager.acceptedDate {
                    Text("Accepted on: \(date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Current Version: \(TermsManager.currentTermsVersion) (Explicit acceptance required)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Button {
                showingTermsSheet = true
            } label: {
                Text("Review Terms & Conditions")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                    .padding(.horizontal, DesignTokens.Spacing.medium)
                    .padding(.vertical, 8)
                    .background(Color.NeuroPulse.brandTeal.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
            }
            .padding(.top, 4)
        }
        .padding(DesignTokens.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
    }
    
    private var termsStatusBadge: some View {
        let isAccepted = termsManager.isAccepted
        let label = isAccepted ? "Accepted" : "Pending"
        let color = isAccepted ? Color.NeuroPulse.brandTeal : Color.secondary
        
        return Text(label)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(color)
            .padding(.horizontal, DesignTokens.Spacing.small)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.12)))
    }
    
    private var consentStatusCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                Image(systemName: "hand.raised.square.on.square.fill")
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                Text("Data-Sharing Consent")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                consentDecisionBadge
            }
            
            Divider()
            
            Text("Purpose: Personalization of recommendations based on authorized motor and wellness trends (v\(consentManager.consentVersion)).")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: DesignTokens.Spacing.small) {
                if consentManager.isPersonalizationConsented {
                    Button(role: .destructive) {
                        withdrawConsent()
                    } label: {
                        Text("Withdraw Consent")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.NeuroPulse.error)
                            .padding(.horizontal, DesignTokens.Spacing.medium)
                            .padding(.vertical, 8)
                            .background(Color.NeuroPulse.error.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
                    }
                } else {
                    Button {
                        showingConsentSheet = true
                    } label: {
                        Text("Review Consent Options")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.NeuroPulse.brandTeal)
                            .padding(.horizontal, DesignTokens.Spacing.medium)
                            .padding(.vertical, 8)
                            .background(Color.NeuroPulse.brandTeal.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(DesignTokens.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
    }
    
    private var consentDecisionBadge: some View {
        let (label, color): (String, Color) = {
            switch consentManager.decision {
            case .granted: return ("Active", Color.NeuroPulse.brandTeal)
            case .declined: return ("Declined", Color.secondary)
            case .withdrawn: return ("Withdrawn", Color.NeuroPulse.error)
            case .undecided: return ("Not Decided", Color.secondary)
            }
        }()
        
        return Text(label)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(color)
            .padding(.horizontal, DesignTokens.Spacing.small)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.12)))
    }
    
    private var remoteDataCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                Image(systemName: "trash.circle")
                    .foregroundStyle(Color.NeuroPulse.error)
                Text("Cloud Data Management")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            Text("Request permanent deletion of all assessment and wellness records synchronized to the backend. Local records on this device will NOT be deleted.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Button(role: .destructive) {
                showingDeleteDataAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete Remote Data")
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, DesignTokens.Spacing.medium)
                .padding(.vertical, 8)
                .background(Color.NeuroPulse.error)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
            }
            .padding(.top, 4)
        }
        .padding(DesignTokens.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
    }
    
    private var actionsSection: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            if authManager.currentMode == .authenticated {
                Button(role: .destructive) {
                    authManager.signOut()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.NeuroPulse.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                            .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
                    )
                }
            } else {
                Button {
                    showingAuthSheet = true
                } label: {
                    HStack {
                        Image(systemName: "person.badge.key.fill")
                        Text("Sign In or Register")
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        LinearGradient(
                            colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.motorPrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                }
            }
            
            Button {
                authManager.returnToWelcome()
                dismiss()
            } label: {
                Text("Return to Welcome Screen")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
