//
//  AuthenticationView.swift
//  NeuroPulseAI
//
//  Secure Sign In and Account Creation Screen.
//  Uses Argon2id and JWT via the FastAPI backend.
//

import SwiftUI

public struct AuthenticationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var isRegisterMode: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    
    public init(initialMode: WelcomeLandingView.AuthSheetMode = .signIn) {
        _isRegisterMode = State(initialValue: initialMode == .createAccount)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.large) {
                    // MARK: - Mode Picker
                    Picker("Authentication Mode", selection: $isRegisterMode) {
                        Text("Sign In").tag(false)
                        Text("Create Account").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, DesignTokens.Spacing.small)
                    
                    // MARK: - Header Text
                    VStack(spacing: DesignTokens.Spacing.xSmall) {
                        Text(isRegisterMode ? "Create Your Account" : "Welcome Back")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text(isRegisterMode
                             ? "Register with email to manage your account and optionally personalize recommendations."
                             : "Sign in with your email to access your authenticated session.")
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
                                SecureField(isRegisterMode ? "Minimum 8 characters" : "Enter your password", text: $password)
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
                    
                    // MARK: - Submit Button
                    Button {
                        submitAuth()
                    } label: {
                        HStack {
                            if authManager.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 4)
                            }
                            Text(isRegisterMode ? "Create Account" : "Sign In")
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
                    
                    // MARK: - Cancel / Continue Locally
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, DesignTokens.Spacing.small)
                }
                .padding(.horizontal, DesignTokens.Spacing.large)
                .padding(.vertical, DesignTokens.Spacing.large)
            }
            .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
            .navigationTitle(isRegisterMode ? "Register" : "Sign In")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func submitAuth() {
        Task {
            let success: Bool
            if isRegisterMode {
                success = await authManager.register(email: email, password: password)
            } else {
                success = await authManager.signIn(email: email, password: password)
            }
            
            if success {
                dismiss()
            }
        }
    }
}
