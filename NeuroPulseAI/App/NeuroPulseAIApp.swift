//
//  NeuroPulseAIApp.swift
//  NeuroPulseAI
//
//  Application entry point with root state machine routing based on AuthManager.flowState:
//  - Welcome / Onboarding Landing Page (for first launch and signed-out users)
//  - Non-dismissible Terms & Conditions checkpoint (when terms acceptance is required)
//  - Non-dismissible Data-Sharing Consent checkpoint (when consent decision is undecided)
//  - Home Dashboard (only once requirements are complete, or for Local-Only mode)
//

import SwiftUI

@main
struct NeuroPulseAIApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch authManager.flowState {
                case .welcome:
                    WelcomeLandingView()
                case .termsRequired:
                    NavigationStack {
                        TermsAndConditionsView()
                    }
                case .dataSharingConsentRequired:
                    NavigationStack {
                        PersonalizationConsentView()
                    }
                case .localOnly, .ready:
                    HomeView()
                }
            }
        }
    }
}
