//
//  WelcomeLandingView.swift
//  NeuroPulseAI
//
//  Welcome and onboarding landing screen.
//  Offers two equally supported operating paths:
//  - Account Authentication (Sign In / Register)
//  - Local-Only Operation (No Account Required)
//

import SwiftUI

public struct WelcomeLandingView: View {
    @ObservedObject private var authManager = AuthManager.shared
    public enum AuthDestination: String, Identifiable {
        case signIn = "signIn"
        case createAccount = "createAccount"

        public var id: String { rawValue }
    }
    public typealias AuthSheetMode = AuthDestination

    @State private var activeAuthDestination: AuthDestination? = nil

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.xLarge) {
                    // MARK: - App Branding
                    brandingHeader

                    // MARK: - Core Capabilities Overview
                    capabilitiesSection

                    // MARK: - Action Choices
                    actionsSection

                    // MARK: - Privacy Guarantee Banner
                    privacyDisclosure
                }
                .padding(.horizontal, DesignTokens.Spacing.large)
                .padding(.top, DesignTokens.Spacing.large)
                .padding(.bottom, DesignTokens.Spacing.xxLarge)
            }
            .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
            .sheet(item: $activeAuthDestination) { destination in
                switch destination {
                case .signIn:
                    SignInView(onSwitchToRegister: {
                        activeAuthDestination = .createAccount
                    })
                case .createAccount:
                    CreateAccountView(onSwitchToSignIn: {
                        activeAuthDestination = .signIn
                    })
                }
            }
        }
    }

    // MARK: - Subviews

    private var brandingHeader: some View {
        VStack(spacing: DesignTokens.Spacing.small) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.motorPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.NeuroPulse.brandTeal.opacity(0.3), radius: 12, y: 6)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, DesignTokens.Spacing.xSmall)

            Text("NeuroPulseAI")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.motorPrimary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Unified Motor Health & Mindful Wellness")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, DesignTokens.Spacing.medium)
    }

    private var capabilitiesSection: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            HStack(spacing: DesignTokens.Spacing.medium) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                        .fill(Color.NeuroPulse.motorPrimary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.NeuroPulse.motorPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Motor Health Assessments")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Alternating finger tapping, center-deviation metrics, and spiral tracing.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(DesignTokens.Spacing.medium)
            .background(Color.NeuroPulse.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
            )

            HStack(spacing: DesignTokens.Spacing.medium) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                        .fill(Color.NeuroPulse.mindEasePrimary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "wind")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("MindEase Wellness Tools")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Guided visual breathing, mindfulness pauses, and self-check-ins.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(DesignTokens.Spacing.medium)
            .background(Color.NeuroPulse.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
            )
        }
    }

    private var actionsSection: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            // Mode A Action: Sign In
            Button {
                activeAuthDestination = .signIn
            } label: {
                HStack {
                    Image(systemName: "person.badge.key.fill")
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
                .font(.body)
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
                .shadow(color: Color.NeuroPulse.brandTeal.opacity(0.3), radius: 8, y: 4)
            }
            .accessibilityLabel("Sign in to your account")

            // Mode A Action: Create Account
            Button {
                activeAuthDestination = .createAccount
            } label: {
                HStack {
                    Image(systemName: "person.crop.circle.badge.plus")
                    Text("Create An Account")
                        .fontWeight(.medium)
                }
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.NeuroPulse.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                        .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
                )
            }
            .accessibilityLabel("Create a new account")

            // Divider with OR
            HStack {
                Rectangle().fill(Color.NeuroPulse.subtleBorder).frame(height: 1)
                Text("OR")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DesignTokens.Spacing.small)
                Rectangle().fill(Color.NeuroPulse.subtleBorder).frame(height: 1)
            }
            .padding(.vertical, DesignTokens.Spacing.xSmall)

            // Mode B Action: Continue Locally
            Button {
                authManager.continueLocally()
            } label: {
                VStack(spacing: 4) {
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Continue Locally")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    Text("No account required • 100% on-device functionality")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(Color.NeuroPulse.brandTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.medium)
                .background(Color.NeuroPulse.brandTeal.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                        .stroke(Color.NeuroPulse.brandTeal.opacity(0.3), lineWidth: 1.5)
                )
            }
            .accessibilityLabel("Continue using the app locally without an account")
        }
    }

    private var privacyDisclosure: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.NeuroPulse.brandTeal)

            VStack(alignment: .leading, spacing: 2) {
                Text("Privacy Notice")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text("Account authentication and permission to share activity data are completely separate decisions. Choosing local-only operation preserves all motor assessments, spiral tests, and MindEase wellness tools without uploading records.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignTokens.Spacing.medium)
        .background(Color.NeuroPulse.cardBackground.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
    }
}
