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
                    .fill(Color.NeoBrutal.ink)
                    .frame(width: 72, height: 72)
                    .offset(x: 3, y: 3)
                Circle()
                    .fill(Color.NeoBrutal.lavender)
                    .frame(width: 72, height: 72)
                Circle()
                    .stroke(Color.NeoBrutal.ink, lineWidth: 2)
                    .frame(width: 72, height: 72)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.NeoBrutal.ink)
            }
            .padding(.bottom, DesignTokens.Spacing.xSmall)

            Text("Welcome")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)

            Text("NeuroPulseAI")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)

            Text("Unified Motor Health & Mindful Wellness")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, DesignTokens.Spacing.medium)
    }

    private var capabilitiesSection: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            HStack(spacing: DesignTokens.Spacing.medium) {
                BrutalIconTile(iconName: "hand.tap.fill", size: 48, iconSize: 22, bg: Color.NeoBrutal.lavender)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Motor Health Assessments")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)
                    Text("Alternating finger tapping, deviation metrics, and spiral tracing.")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)
                }
                Spacer()
            }
            .padding(16)
            .brutalRow(cornerRadius: 16)

            HStack(spacing: DesignTokens.Spacing.medium) {
                BrutalIconTile(iconName: "wind", size: 48, iconSize: 22, bg: Color.NeoBrutal.mint)

                VStack(alignment: .leading, spacing: 3) {
                    Text("MindEase Wellness Tools")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)
                    Text("Guided visual breathing, mindfulness pauses, and self-check-ins.")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)
                }
                Spacer()
            }
            .padding(16)
            .brutalRow(cornerRadius: 16)
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 14) {
            // Mode A Action: Sign In
            Button {
                activeAuthDestination = .signIn
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Sign In")
                }
            }
            .buttonStyle(BrutalButtonStyle(fill: Color.NeoBrutal.lavender))
            .accessibilityLabel("Sign in to your account")

            // Mode A Action: Create Account
            Button {
                activeAuthDestination = .createAccount
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Create An Account")
                }
            }
            .buttonStyle(BrutalSecondaryButtonStyle())
            .accessibilityLabel("Create a new account")

            // Divider with OR
            HStack {
                Rectangle().fill(Color.NeoBrutal.ink).frame(height: 1.5)
                Text("OR")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.mutedText)
                    .padding(.horizontal, DesignTokens.Spacing.small)
                Rectangle().fill(Color.NeoBrutal.ink).frame(height: 1.5)
            }
            .padding(.vertical, DesignTokens.Spacing.xSmall)

            // Mode B Action: Continue Locally
            Button {
                authManager.continueLocally()
            } label: {
                HStack(spacing: DesignTokens.Spacing.small) {
                    Image(systemName: "iphone.gen3")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Continue Locally")
                }
            }
            .buttonStyle(BrutalSecondaryButtonStyle())
            .accessibilityLabel("Continue using the app locally without an account")
        }
    }

    private var privacyDisclosure: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.NeoBrutal.ink)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text("Privacy Guarantee")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)
                Text("Account authentication and permission to share activity data are separate decisions. Local operation preserves all motor assessments without uploading records.")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .brutalRow(cornerRadius: 16)
    }
}
