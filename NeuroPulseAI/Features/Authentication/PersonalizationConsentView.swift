//
//  PersonalizationConsentView.swift
//  NeuroPulseAI
//
//  Dedicated consent disclosure and decision screen for personalized recommendations.
//  Strictly enforces separate decisions for account creation vs. data sharing.
//  Guaranteed blocking checkpoint: cannot be dismissed or bypassed without an explicit decision.
//

import SwiftUI

public struct PersonalizationConsentView: View {
    @ObservedObject private var consentManager = ConsentManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var isProcessing: Bool = false
    
    public var onCompletion: (() -> Void)?
    
    public init(onCompletion: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                // MARK: - Header
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                    ZStack {
                        Circle()
                            .fill(Color.NeuroPulse.brandTeal.opacity(0.15))
                            .frame(width: 54, height: 54)
                        Image(systemName: "hand.raised.square.on.square.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.NeuroPulse.brandTeal)
                    }
                    
                    Text("Personalization Consent")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Version 1.0 • Purpose-Specific Authorization")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.NeuroPulse.brandTeal)
                }
                
                // MARK: - Required Privacy Decision Notice Banner
                HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.NeuroPulse.brandTeal)
                        .padding(.top, 1)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Required Privacy Decision")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        Text("Please choose whether you allow data sharing. Your decision will be saved for this account.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(14)
                .background(Color.NeuroPulse.brandTeal.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.NeuroPulse.brandTeal.opacity(0.3), lineWidth: 0.75)
                )
                
                // MARK: - Purpose & Scope Disclosure
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                    disclosureItem(
                        icon: "sparkles",
                        title: "Why we ask for permission",
                        description: "To generate personalized pacing recommendations and wellness insights tailored to your actual rhythm consistency and recovery trends."
                    )
                    
                    disclosureItem(
                        icon: "waveform.path.ecg",
                        title: "What data is shared",
                        description: "Only newly completed motor assessment metrics (tapping cadence, rhythm CV, center deviation, spiral RMSE) and wellness check-in scores."
                    )
                    
                    disclosureItem(
                        icon: "server.rack",
                        title: "Where data is sent and stored",
                        description: "Records are sent securely over HTTPS to the NeuroPulseAI backend and stored strictly isolated under your authenticated account."
                    )
                    
                    disclosureItem(
                        icon: "arrow.uturn.backward.circle.fill",
                        title: "You can withdraw anytime",
                        description: "You may withdraw consent or request complete deletion of remote records in Settings at any time without losing local history."
                    )
                    
                    disclosureItem(
                        icon: "shield.slash.fill",
                        title: "What happens if you decline",
                        description: "The entire app remains fully functional. Assessments, spiral tests, and MindEase activities continue to save locally on your device with zero cloud uploads."
                    )
                }
                .padding(16)
                .background(Color.NeuroPulse.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                )
                
                // MARK: - Explicit Decision Buttons
                VStack(spacing: DesignTokens.Spacing.medium) {
                    // Option 1: Grant Consent
                    Button {
                        handleDecision(granted: true)
                    } label: {
                        HStack(spacing: 8) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 4)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            Text(isProcessing ? "Saving..." : "Allow Data Sharing for Personalization")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.motorPrimary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                        .shadow(color: Color.NeuroPulse.brandTeal.opacity(0.25), radius: 6, y: 3)
                    }
                    .disabled(isProcessing)
                    .accessibilityLabel("Allow data sharing for personalized recommendations")
                    
                    // Option 2: Decline Consent
                    Button {
                        handleDecision(granted: false)
                    } label: {
                        HStack(spacing: 8) {
                            if isProcessing {
                                ProgressView()
                                    .padding(.trailing, 4)
                            } else {
                                Image(systemName: "xmark.circle")
                                    .font(.system(size: 18, weight: .medium))
                            }
                            Text(isProcessing ? "Saving..." : "Decline & Keep Data Local Only")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.NeuroPulse.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                        )
                    }
                    .disabled(isProcessing)
                    .accessibilityLabel("Decline data sharing and keep records on device only")
                    
                    // Option 3: Sign Out & Return Later
                    Button {
                        guard !isProcessing else { return }
                        authManager.signOut()
                    } label: {
                        Text("Sign Out & Return Later")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                    .disabled(isProcessing)
                    .padding(.top, 4)
                }
                .padding(.top, DesignTokens.Spacing.small)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.vertical, DesignTokens.Spacing.large)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(true)
    }
    
    private func disclosureItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.NeuroPulse.brandTeal)
                .frame(width: 24, alignment: .center)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func handleDecision(granted: Bool) {
        guard !isProcessing else { return }
        isProcessing = true
        Task {
            _ = await authManager.recordConsentDecisionAndAdvance(granted: granted)
            if let customCompletion = onCompletion {
                customCompletion()
            }
            isProcessing = false
        }
    }
}
