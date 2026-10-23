//
//  HomeView.swift
//  NeuroPulseAI
//
//  Main application dashboard providing discovery and navigation to
//  Motor Health assessments and MindEase wellness tools.
//

import SwiftUI

public struct HomeView: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    // MARK: - App Brand Header
                    headerSection
                    
                    // MARK: - Privacy & Architecture Status Pill
                    privacyStatusPill
                    
                    // MARK: - Mode Selection Cards
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        NavigationLink {
                            MotorHealthHomeView()
                        } label: {
                            ModeCardView(
                                title: "Motor Health",
                                category: "Assessment",
                                subtitle: "Record fine-motor dexterity, tapping rhythm consistency, and spiral trajectory stability.",
                                iconName: "hand.tap.fill",
                                gradientColors: [
                                    Color.NeuroPulse.motorPrimary,
                                    Color.NeuroPulse.motorSecondary
                                ],
                                features: ["Finger Tapping", "Spiral Tracing", "Cadence Metrics"]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink {
                            MindEaseHomeView()
                        } label: {
                            ModeCardView(
                                title: "MindEase",
                                category: "Wellness",
                                subtitle: "Find calm and reset with guided visual breathing, mindfulness, and relaxation check-ins.",
                                iconName: "wind",
                                gradientColors: [
                                    Color.NeuroPulse.mindEasePrimary,
                                    Color.NeuroPulse.mindEaseSecondary
                                ],
                                features: ["Guided Breathing", "Mindfulness", "Check-ins"]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // MARK: - Non-Diagnostic Safety Disclosure
                    DisclaimerBanner()
                }
                .padding(.horizontal, DesignTokens.Spacing.large)
                .padding(.top, DesignTokens.Spacing.medium)
                .padding(.bottom, DesignTokens.Spacing.xxLarge)
            }
            .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.motorPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.NeuroPulse.brandTeal.opacity(0.35), radius: 8, x: 0, y: 4)
                
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("NeuroPulse AI")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Neurological Health & Mindful Wellness")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("NeuroPulse AI, Neurological Health and Mindful Wellness")
    }
    
    private var privacyStatusPill: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            Image(systemName: "lock.shield.fill")
                .font(.caption)
                .foregroundStyle(Color.NeuroPulse.success)
            
            Text("On-Device Local Processing")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text("Private & Offline")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(Color.NeuroPulse.success)
        }
        .padding(.horizontal, DesignTokens.Spacing.medium)
        .padding(.vertical, DesignTokens.Spacing.small)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("On-device local processing. Private and offline.")
    }
}

#Preview {
    HomeView()
}
