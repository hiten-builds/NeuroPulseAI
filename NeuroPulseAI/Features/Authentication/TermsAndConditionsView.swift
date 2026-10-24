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
                    BrutalIconTile(iconName: "doc.text.magnifyingglass", size: 54, iconSize: 26, bg: Color.NeoBrutal.lavender)
                    
                    Text("Terms & Conditions")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)
                    
                    HStack(spacing: 8) {
                        BrutalBadge("Version \(TermsManager.currentTermsVersion)", style: .complete)
                        
                        Text("• Required for Account Access")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.mutedText)
                    }
                }
                
                // MARK: - Required Decision Notice Banner
                HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.NeoBrutal.ink)
                        .padding(.top, 1)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Required Decision")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.ink)
                        Text("You must review and accept the Terms & Conditions to continue into the application.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(14)
                .brutalRow(cornerRadius: 14, fill: Color.NeoBrutal.peach, outlineWidth: 2)
                
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
                .padding(18)
                .brutalCard(cornerRadius: 20, fill: .white)
                
                // MARK: - Acceptance Actions
                VStack(spacing: 12) {
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
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.NeoBrutal.ink))
                                    .padding(.trailing, 4)
                            } else {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            Text(isProcessing ? "Saving..." : "Agree & Continue")
                        }
                    }
                    .buttonStyle(BrutalButtonStyle(fill: Color.NeoBrutal.lavender))
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
                    }
                    .buttonStyle(BrutalSecondaryButtonStyle())
                    .disabled(isProcessing)
                }
                .padding(.top, DesignTokens.Spacing.small)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.vertical, DesignTokens.Spacing.large)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(true)
    }
    
    private func termsSection(number: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Text(number)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color.NeoBrutal.ink))
                
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)
            }
            
            Text(body)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 30)
        }
    }
}
