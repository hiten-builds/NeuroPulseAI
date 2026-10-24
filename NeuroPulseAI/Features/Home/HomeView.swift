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

                    // MARK: - Primary Mode Selection Cards
                    VStack(spacing: 12) {
                        NavigationLink {
                            MotorHealthHomeView()
                        } label: {
                            ModeCardView(
                                title: "Motor Health",
                                iconName: "hand.tap.fill",
                                gradientColors: [
                                    Color.NeuroPulse.motorPrimary,
                                    Color.NeuroPulse.motorSecondary
                                ]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink {
                            MindEaseHomeView()
                        } label: {
                            ModeCardView(
                                title: "MindEase",
                                iconName: "wind",
                                gradientColors: [
                                    Color.NeuroPulse.mindEasePrimary,
                                    Color.NeuroPulse.mindEaseSecondary
                                ]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Mode 3: Read Mind Waves
                        NavigationLink {
                            ReadMindWavesLandingView()
                        } label: {
                            ModeCardView(
                                title: "Read Mind Waves",
                                iconName: "waveform.path.ecg",
                                gradientColors: [
                                    Color.NeuroPulse.brandTeal,
                                    Color.NeuroPulse.mindEaseSecondary
                                ]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    // MARK: - Secondary Experiences (Insights & Activity)
                    VStack(spacing: 12) {

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
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                }

                                Text("Recommendations")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Text(isCloudPersonalized ? "Personalized" : "Local")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(isCloudPersonalized ? Color.NeuroPulse.brandTeal : Color.NeuroPulse.motorPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill((isCloudPersonalized ? Color.NeuroPulse.brandTeal : Color.NeuroPulse.motorPrimary).opacity(0.12))
                                    )

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.NeuroPulse.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Saved Records Card
                        NavigationLink {
                            SavedRecordsView()
                        } label: {
                            HStack(spacing: DesignTokens.Spacing.medium) {
                                ZStack {
                                    Circle()
                                        .fill(Color.NeuroPulse.brandTeal.opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color.NeuroPulse.brandTeal)
                                }

                                Text("Activity History")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.NeuroPulse.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
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
                    .shadow(color: Color.NeuroPulse.brandTeal.opacity(0.25), radius: 6, x: 0, y: 3)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text("NeuroPulse AI")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("Neurological Health & Mindful Wellness")
                    .font(.footnote)
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
                        .frame(width: 42, height: 42)
                    Image(systemName: authManager.currentMode == .authenticated ? "person.crop.circle.fill" : "person.crop.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.NeuroPulse.brandTeal)
                }
                .overlay(
                    Circle()
                        .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                )
            }
            .accessibilityLabel("Account and Privacy Settings")
        }
    }

    private var privacyStatusPill: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            Image(systemName: isCloudPersonalized ? "cloud.shield.fill" : "lock.shield.fill")
                .font(.footnote)
                .foregroundStyle(Color.NeuroPulse.success)

            Text(statusTitle)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Spacer()

            Text(statusSubtitle)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(Color.NeuroPulse.success)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
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
