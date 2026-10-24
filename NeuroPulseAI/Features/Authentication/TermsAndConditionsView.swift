//
//  TermsAndConditionsView.swift
//  NeuroPulseAI
//
//  Terms & Conditions presentation and explicit acceptance screen.
//  Presents versioned terms before onboarding completes.
//  Guaranteed blocking checkpoint: cannot be dismissed or bypassed without an explicit decision.
//

import SwiftUI

public struct TermsAndConditionsView: View {
    @ObservedObject private var termsManager = TermsManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var isProcessing: Bool = false
    
    public var onAccept: (() -> Void)?
    public var onDecline: (() -> Void)?
    
    public init(onAccept: (() -> Void)? = nil, onDecline: (() -> Void)? = nil) {
        self.onAccept = onAccept
        self.onDecline = onDecline
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
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.NeuroPulse.brandTeal)
                    }
                    
                    Text("Terms & Conditions")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 6) {
                        Text("Version \(TermsManager.currentTermsVersion)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.NeuroPulse.brandTeal)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.NeuroPulse.brandTeal.opacity(0.12)))
                        
                        Text("• Required for Account Access")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // MARK: - Required Decision Notice Banner
                HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.NeuroPulse.brandTeal)
                        .padding(.top, 1)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Required Decision")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        Text("You must review and accept the Terms & Conditions to continue into the application.")
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
                
                // MARK: - Terms Content Sections
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                    termsSection(
                        number: "1",
                        title: "Non-Diagnostic Informational Scope",
                        body: "NeuroPulseAI provides fine-motor assessments and mindful wellness activities for personal tracking. Metrics such as tapping cadence, center deviation, and spiral RMSE do NOT constitute medical diagnoses, disease probabilities, or clinical treatment plans. Always consult a licensed healthcare professional for medical concerns."
                    )
                    
                    termsSection(
                        number: "2",
                        title: "Account-Scoped Data Ownership",
                        body: "All assessment sessions, activity history, and wellness check-in records are strictly associated with your authenticated account identifier. Your data is isolated and cannot be accessed, viewed, or combined with records from other user accounts on this device or the cloud."
                    )
                    
                    termsSection(
                        number: "3",
                        title: "Separate Data-Sharing Authorization",
                        body: "Account authentication and permission to share records are distinct choices. Agreeing to these Terms does NOT grant permission to upload your health data. Cloud-based recommendation personalization requires an explicit, separate data-sharing consent that you can grant, decline, or withdraw at any time."
                    )
                    
                    termsSection(
                        number: "4",
                        title: "Safe Usage & Physical Pacing",
                        body: "You agree to conduct motor assessments in a comfortable, well-lit environment on a stable surface. You may pause, cancel, or stop any assessment at any time without penalty."
                    )
                }
                .padding(16)
                .background(Color.NeuroPulse.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                )
                
                // MARK: - Acceptance Actions
                VStack(spacing: DesignTokens.Spacing.medium) {
                    Button {
                        guard !isProcessing else { return }
                        isProcessing = true
                        authManager.acceptTermsAndAdvance()
                        if let customAccept = onAccept {
                            customAccept()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 4)
                            } else {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            Text(isProcessing ? "Saving..." : "Agree & Continue")
                                .font(.system(size: 17, weight: .semibold))
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
                    .accessibilityLabel("Agree to Terms & Conditions and continue")
                    
                    Button {
                        guard !isProcessing else { return }
                        if let customDecline = onDecline {
                            customDecline()
                        } else {
                            authManager.signOut()
                        }
                    } label: {
                        Text("Decline & Sign Out")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.NeuroPulse.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                            )
                    }
                    .disabled(isProcessing)
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
    
    private func termsSection(number: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Text(number)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.NeuroPulse.brandTeal))
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            
            Text(body)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 28)
        }
    }
}
