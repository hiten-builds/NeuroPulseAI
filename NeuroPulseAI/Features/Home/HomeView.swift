//
//  HomeView.swift
//  NeuroPulseAI
//
//  Main application dashboard providing discovery and navigation to
//  Motor Health assessments, MindEase wellness tools, Saved Records,
//  and Personalized Recommendations.
//

import SwiftUI

public struct HomeView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var consentManager = ConsentManager.shared
    @State private var showingAccountSettings = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    // MARK: - App Brand Header & Account Settings Action
                    headerSection

                    // MARK: - Privacy & Architecture Status Pill
                    privacyStatusPill

                    // MARK: - Mode Selection Cards
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        NavigationLink {
                            MotorHealthHomeView()
                        } label: {
                            ModeCardView(
                                title: "Motor Health",
                                category: "Assessment",
                                subtitle: "Record fine-motor dexterity, tapping rhythm consistency, and spiral trajectory stability.",
                                iconName: "hand.tap.fill",
                                gradientColors: [
                                    Color.NeuroPulse.motorPrimary,
                                    Color.NeuroPulse.motorSecondary
                                ],
                                features: ["Finger Tapping", "Spiral Tracing", "Cadence Metrics"]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink {
                            MindEaseHomeView()
                        } label: {
                            ModeCardView(
                                title: "MindEase",
                                category: "Wellness",
                                subtitle: "Find calm and reset with guided visual breathing, mindfulness, and relaxation check-ins.",
                                iconName: "wind",
                                gradientColors: [
                                    Color.NeuroPulse.mindEasePrimary,
                                    Color.NeuroPulse.mindEaseSecondary
                                ],
                                features: ["Guided Breathing", "Mindfulness", "Check-ins"]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Mode 3: Read Mind Waves
                        NavigationLink {
                            ReadMindWavesLandingView()
                        } label: {
                            ModeCardView(
                                title: "Read Mind Waves",
                                category: "Brain Waves",
                                subtitle: "Connect an EEG headset to explore your brain wave activity.",
                                iconName: "waveform.path.ecg",
                                gradientColors: [
                                    Color.NeuroPulse.brandTeal,
                                    Color.NeuroPulse.mindEaseSecondary
                                ],
                                features: ["Brain Waves", "Headset Pairing", "EEG Activity"]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Recommendations Card
                        NavigationLink {
                            RecommendationsView()
                        } label: {
                            HStack(spacing: DesignTokens.Spacing.medium) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.motorPrimary],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                                    HStack {
                                        Text("Recommendations")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Text(isCloudPersonalized ? "Cloud Personalized" : "Local Guidance")
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(isCloudPersonalized ? Color.NeuroPulse.brandTeal : Color.NeuroPulse.motorPrimary)
                                            .padding(.horizontal, DesignTokens.Spacing.small)
                                            .padding(.vertical, 2)
                                            .background(
                                                Capsule()
                                                    .fill((isCloudPersonalized ? Color.NeuroPulse.brandTeal : Color.NeuroPulse.motorPrimary).opacity(0.12))
                                            )
                                    }
                                    Text("Explainable pacing suggestions and recovery insights based on your activities.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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
                        .buttonStyle(PlainButtonStyle())

                        // Saved Records Card
                        NavigationLink {
                            SavedRecordsView()
                        } label: {
                            HStack(spacing: DesignTokens.Spacing.medium) {
                                ZStack {
                                    Circle()
                                        .fill(Color.NeuroPulse.brandTeal.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(Color.NeuroPulse.brandTeal)
                                }

                                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                                    HStack {
                                        Text("Activity History")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Text("Saved Records")
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color.NeuroPulse.brandTeal)
                                            .padding(.horizontal, DesignTokens.Spacing.small)
                                            .padding(.vertical, 2)
                                            .background(Capsule().fill(Color.NeuroPulse.brandTeal.opacity(0.12)))
                                    }
                                    Text("Inspect on-device history, alternating tapping metrics, and MindEase records.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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
                        .buttonStyle(PlainButtonStyle())
                    }

                    // MARK: - Non-Diagnostic Safety Disclosure
                    DisclaimerBanner()
                }
                .padding(.horizontal, DesignTokens.Spacing.large)
                .padding(.top, DesignTokens.Spacing.medium)
                .padding(.bottom, DesignTokens.Spacing.xxLarge)
            }
            .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingAccountSettings) {
                NavigationStack {
                    AccountSettingsView()
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Done") {
                                    showingAccountSettings = false
                                }
                            }
                        }
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var isCloudPersonalized: Bool {
        return authManager.currentMode == .authenticated && consentManager.isPersonalizationConsented
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.motorPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.NeuroPulse.brandTeal.opacity(0.35), radius: 8, x: 0, y: 4)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("NeuroPulse AI")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("Neurological Health & Mindful Wellness")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Account & Privacy Button
            Button {
                showingAccountSettings = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.NeuroPulse.cardBackground)
                        .frame(width: 40, height: 40)
                    Image(systemName: authManager.currentMode == .authenticated ? "person.crop.circle.fill" : "person.crop.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.NeuroPulse.brandTeal)
                }
                .overlay(
                    Circle()
                        .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
                )
            }
            .accessibilityLabel("Account and Privacy Settings")
        }
    }

    private var privacyStatusPill: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            Image(systemName: isCloudPersonalized ? "cloud.shield.fill" : "lock.shield.fill")
                .font(.caption)
                .foregroundStyle(Color.NeuroPulse.success)

            Text(statusTitle)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Spacer()

            Text(statusSubtitle)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(Color.NeuroPulse.success)
        }
        .padding(.horizontal, DesignTokens.Spacing.medium)
        .padding(.vertical, DesignTokens.Spacing.small)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
    }

    private var statusTitle: String {
        switch authManager.currentMode {
        case .localOnly:
            return "Local-Only Operation"
        case .authenticated:
            return consentManager.isPersonalizationConsented ? "Authenticated Account" : "Authenticated (Local Storage)"
        case .welcome:
            return "Local-Only Operation"
        }
    }

    private var statusSubtitle: String {
        switch authManager.currentMode {
        case .localOnly:
            return "Private & On-Device"
        case .authenticated:
            return consentManager.isPersonalizationConsented ? "Cloud Personalized" : "Uploads Blocked"
        case .welcome:
            return "Private & On-Device"
        }
    }
}

#Preview {
    HomeView()
}
