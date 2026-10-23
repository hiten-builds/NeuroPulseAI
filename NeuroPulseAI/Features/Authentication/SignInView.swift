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
                        ZStack {
                            Circle()
                                .fill(Color.NeuroPulse.brandTeal.opacity(0.15))
                                .frame(width: 56, height: 56)
                            Image(systemName: "person.badge.key.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(Color.NeuroPulse.brandTeal)
                        }
                        .padding(.top, DesignTokens.Spacing.small)

                        Text("Welcome Back")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Text("Sign in with your email to access your authenticated session.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // MARK: - Input Fields
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Email Address")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(.secondary)
                                TextField("name@example.com", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                            .padding(DesignTokens.Spacing.medium)
                            .background(Color.NeuroPulse.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
                            )
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                                SecureField("Enter your password", text: $password)
                            }
                            .padding(DesignTokens.Spacing.medium)
                            .background(Color.NeuroPulse.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
                            )
                        }
                    }

                    // MARK: - Error Message Banner
                    if let error = authManager.authError {
                        HStack(spacing: DesignTokens.Spacing.small) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.NeuroPulse.error)
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color.NeuroPulse.error)
                            Spacer()
                        }
                        .padding(DesignTokens.Spacing.medium)
                        .background(Color.NeuroPulse.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
                    }

                    // MARK: - Sign In Button
                    Button {
                        submitSignIn()
                    } label: {
                        HStack {
                            if authManager.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 4)
                            }
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.motorPrimary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                        .shadow(color: Color.NeuroPulse.brandTeal.opacity(0.3), radius: 6, y: 3)
                    }
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
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                Text("Create Account")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                            }
                        }
                        .padding(.top, DesignTokens.Spacing.xSmall)
                    }

                    // MARK: - Cancel
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, DesignTokens.Spacing.xSmall)
                }
                .padding(.horizontal, DesignTokens.Spacing.large)
                .padding(.vertical, DesignTokens.Spacing.large)
            }
            .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
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
