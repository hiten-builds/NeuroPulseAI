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
                            .font(.footnote)
                            .foregroundStyle(.secondary)
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
                                SecureField(isRegisterMode ? "Minimum 8 characters" : "Enter your password", text: $password)
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
                    
                    // MARK: - Submit Button
                    Button {
                        submitAuth()
                    } label: {
                        HStack {
                            if authManager.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.NeoBrutal.ink))
                                    .padding(.trailing, 4)
                            }
                            Text(isRegisterMode ? "Create Account" : "Sign In")
                        }
                    }
                    .buttonStyle(BrutalButtonStyle(fill: Color.NeoBrutal.lavender))
                    .disabled(authManager.isAuthenticating || email.isEmpty || password.isEmpty)
                    .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                }
                .padding(.horizontal, DesignTokens.Spacing.large)
                .padding(.vertical, DesignTokens.Spacing.large)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle(isRegisterMode ? "Register" : "Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
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
