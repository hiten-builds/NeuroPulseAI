//
//  CreateAccountView.swift
//  NeuroPulseAI
//
//  Dedicated Account Registration / Create Account screen.
//  Provides new user registration and routes to onboarding state machine.
//

import SwiftUI

public struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var localValidationMessage: String? = nil

    public var onSwitchToSignIn: (() -> Void)?

    public init(onSwitchToSignIn: (() -> Void)? = nil) {
        self.onSwitchToSignIn = onSwitchToSignIn
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.large) {
                    // MARK: - Header Text
                    VStack(spacing: DesignTokens.Spacing.xSmall) {
                        BrutalIconTile(iconName: "person.crop.circle.badge.plus", size: 56, iconSize: 26, bg: Color.NeoBrutal.mint)
                            .padding(.top, DesignTokens.Spacing.small)

                        Text("Create Your Account")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.ink)

                        Text("Register with email to manage your account and optionally personalize recommendations.")
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
                            Text("Password (Minimum 8 characters)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.ink)

                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color.NeoBrutal.mutedText)
                                SecureField("Create password", text: $password)
                                    .font(.system(size: 16, design: .rounded))
                            }
                            .brutalInput(isFocused: !password.isEmpty)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Confirm Password")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.ink)

                            HStack {
                                Image(systemName: "lock.rotation")
                                    .foregroundStyle(Color.NeoBrutal.mutedText)
                                SecureField("Re-enter password", text: $confirmPassword)
                                    .font(.system(size: 16, design: .rounded))
                            }
                            .brutalInput(isFocused: !confirmPassword.isEmpty)
                        }
                    }

                    // MARK: - Error Message Banner
                    if let message = activeErrorMessage {
                        HStack(spacing: DesignTokens.Spacing.small) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.NeoBrutal.alertRed)
                            Text(message)
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

                    // MARK: - Submit Button
                    Button {
                        submitRegister()
                    } label: {
                        HStack {
                            if authManager.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.NeoBrutal.ink))
                                    .padding(.trailing, 4)
                            }
                            Text("Create Account")
                        }
                    }
                    .buttonStyle(BrutalButtonStyle(fill: Color.NeoBrutal.lavender))
                    .disabled(authManager.isAuthenticating || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                    .opacity((email.isEmpty || password.isEmpty || confirmPassword.isEmpty) ? 0.6 : 1.0)
                    .accessibilityLabel("Create a new account")

                    // MARK: - Switch to Sign In
                    if let onSwitchToSignIn = onSwitchToSignIn {
                        Button {
                            onSwitchToSignIn()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Already have an account?")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundStyle(Color.NeoBrutal.mutedText)
                                Text("Sign In")
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
            .navigationTitle("Create Account")
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

    private var activeErrorMessage: String? {
        if let local = localValidationMessage {
            return local
        }
        return authManager.authError
    }

    private func submitRegister() {
        localValidationMessage = nil

        guard password == confirmPassword else {
            localValidationMessage = "Passwords do not match."
            return
        }

        Task {
            let success = await authManager.register(email: email, password: password)
            if success {
                dismiss()
            }
        }
    }
}
