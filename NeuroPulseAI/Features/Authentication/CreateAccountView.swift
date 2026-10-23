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
                        ZStack {
                            Circle()
                                .fill(Color.NeuroPulse.brandTeal.opacity(0.15))
                                .frame(width: 56, height: 56)
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 26))
                                .foregroundStyle(Color.NeuroPulse.brandTeal)
                        }
                        .padding(.top, DesignTokens.Spacing.small)

                        Text("Create Your Account")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Text("Register with email to manage your account and optionally personalize recommendations.")
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
                            Text("Password (Minimum 8 characters)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                                SecureField("Create password", text: $password)
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
                            Text("Confirm Password")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            HStack {
                                Image(systemName: "lock.rotation")
                                    .foregroundStyle(.secondary)
                                SecureField("Re-enter password", text: $confirmPassword)
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
                    if let message = activeErrorMessage {
                        HStack(spacing: DesignTokens.Spacing.small) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.NeuroPulse.error)
                            Text(message)
                                .font(.caption)
                                .foregroundStyle(Color.NeuroPulse.error)
                            Spacer()
                        }
                        .padding(DesignTokens.Spacing.medium)
                        .background(Color.NeuroPulse.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.small))
                    }

                    // MARK: - Submit Button
                    Button {
                        submitRegister()
                    } label: {
                        HStack {
                            if authManager.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 4)
                            }
                            Text("Create Account")
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
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                Text("Sign In")
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
