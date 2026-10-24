//
//  SignInView.swift
//  NeuroPulseAI
//
//  Dedicated Sign In screen.
//  Provides email & password authentication and routes to onboarding state machine.
//

import SwiftUI

public struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared

    @State private var email: String = ""
    @State private var password: String = ""

    public var onSwitchToRegister: (() -> Void)?

    public init(onSwitchToRegister: (() -> Void)? = nil) {
        self.onSwitchToRegister = onSwitchToRegister
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.large) {
                    // MARK: - Header Text
                    VStack(spacing: DesignTokens.Spacing.xSmall) {
                        BrutalIconTile(iconName: "person.badge.key.fill", size: 56, iconSize: 26, bg: Color.NeoBrutal.lavender)
                            .padding(.top, DesignTokens.Spacing.small)

                        Text("Welcome Back")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.ink)

                        Text("Sign in with your email to access your authenticated session.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.mutedText)
                            .multilineTextAlignment(.center)
                    }

                    // MARK: - Input Fields
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email Address")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.ink)

                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(Color.NeoBrutal.mutedText)
                                TextField("name@example.com", text: $email)
                                    .font(.system(size: 16, design: .rounded))
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                            .brutalInput(isFocused: !email.isEmpty)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.ink)

                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color.NeoBrutal.mutedText)
                                SecureField("Enter your password", text: $password)
                                    .font(.system(size: 16, design: .rounded))
                            }
                            .brutalInput(isFocused: !password.isEmpty)
                        }
                    }

                    // MARK: - Error Message Banner
                    if let error = authManager.authError {
                        HStack(spacing: DesignTokens.Spacing.small) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.NeoBrutal.alertRed)
                            Text(error)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.alertRed)
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.NeoBrutal.badgePendingBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.NeoBrutal.ink, lineWidth: 1.5)
                        )
                    }

                    // MARK: - Sign In Button
                    Button {
                        submitSignIn()
                    } label: {
                        HStack {
                            if authManager.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.NeoBrutal.ink))
                                    .padding(.trailing, 4)
                            }
                            Text("Sign In")
                        }
                    }
                    .buttonStyle(BrutalButtonStyle(fill: Color.NeoBrutal.lavender))
                    .disabled(authManager.isAuthenticating || email.isEmpty || password.isEmpty)
                    .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                    .accessibilityLabel("Sign in to your account")

                    // MARK: - Switch to Register
                    if let onSwitchToRegister = onSwitchToRegister {
                        Button {
                            onSwitchToRegister()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundStyle(Color.NeoBrutal.mutedText)
                                Text("Create Account")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.NeoBrutal.ink)
                                    .underline()
                            }
                        }
                        .padding(.top, DesignTokens.Spacing.xSmall)
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.large)
                .padding(.vertical, DesignTokens.Spacing.large)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func submitSignIn() {
        Task {
            let success = await authManager.signIn(email: email, password: password)
            if success {
                dismiss()
            }
        }
    }
}
