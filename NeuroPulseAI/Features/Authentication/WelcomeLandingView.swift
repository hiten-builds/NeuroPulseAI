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
                        .fill(Color.NeuroPulse.motorPrimary.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.NeuroPulse.motorPrimary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Motor Health Assessments")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Alternating finger tapping, center-deviation metrics, and spiral tracing.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(16)
            .background(Color.NeuroPulse.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
            )

            HStack(spacing: DesignTokens.Spacing.medium) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                        .fill(Color.NeuroPulse.mindEasePrimary.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "wind")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("MindEase Wellness Tools")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Guided visual breathing, mindfulness pauses, and self-check-ins.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(16)
            .background(Color.NeuroPulse.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
            )
        }
    }

    private var actionsSection: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            // Mode A Action: Sign In
            Button {
                activeAuthDestination = .signIn
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Sign In")
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
            .accessibilityLabel("Sign in to your account")

            // Mode A Action: Create Account
            Button {
                activeAuthDestination = .createAccount
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Create An Account")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
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
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DesignTokens.Spacing.small)
                Rectangle().fill(Color.NeuroPulse.subtleBorder).frame(height: 1)
            }
            .padding(.vertical, DesignTokens.Spacing.xSmall)

            // Mode B Action: Continue Locally
            Button {
                authManager.continueLocally()
            } label: {
                VStack(spacing: 3) {
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Continue Locally")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    Text("No account required • 100% on-device functionality")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(Color.NeuroPulse.brandTeal)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.NeuroPulse.brandTeal.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                        .stroke(Color.NeuroPulse.brandTeal.opacity(0.35), lineWidth: 1.25)
                )
            }
            .accessibilityLabel("Continue using the app locally without an account")
        }
    }

    private var privacyDisclosure: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.NeuroPulse.brandTeal)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text("Privacy Guarantee")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text("Account authentication and permission to share activity data are completely separate decisions. Choosing local-only operation preserves all motor assessments, spiral tests, and MindEase wellness tools without uploading records.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
        )
    }
}
