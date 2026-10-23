//
//  MotorHealthHomeView.swift
//  NeuroPulseAI
//
//  Motor Health feature landing screen presenting assessment modules and trend history.
//

import SwiftUI

public struct MotorHealthHomeView: View {
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                // Header Intro
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: "hand.tap.fill")
                            .font(.headline)
                            .foregroundStyle(Color.NeuroPulse.motorPrimary)
                        
                        Text("FINE-MOTOR ASSESSMENTS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .tracking(1.2)
                            .foregroundStyle(Color.NeuroPulse.motorPrimary)
                    }
                    
                    Text("Motor Health")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Evaluate fine-motor control, tap timing consistency, and movement trajectory on-device.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, DesignTokens.Spacing.small)
                
                // Active Test Modules Section
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                    Text("Available Assessments")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    // Finger Tapping Card
                    assessmentCard(
                        title: "Finger-Tapping Test",
                        subtitle: "Timed 15-second protocol measuring cadence, intervals, and rhythm consistency.",
                        icon: "hand.point.up.left.fill",
                        badge: "Protocol v1",
                        badgeColor: Color.NeuroPulse.motorPrimary
                    )
                    
                    // Spiral Tracing Card
                    assessmentCard(
                        title: "Spiral-Tracing Test",
                        subtitle: "Trace a reference curve to measure path deviation, smoothness, and tremor characteristics.",
                        icon: "scribble.variable",
                        badge: "Geometry v1",
                        badgeColor: Color.NeuroPulse.motorSecondary
                    )
                }
                
                // Baseline & History Preview Card
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                    Text("Session History & Trends")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: DesignTokens.Spacing.medium) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.NeuroPulse.motorPrimary.opacity(0.8))
                        
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                            Text("No Sessions Recorded Yet")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Text("Complete a tapping or tracing assessment to establish your personal baseline.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(DesignTokens.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.NeuroPulse.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                            .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
                    )
                }
                
                // Disclaimer Banner
                DisclaimerBanner()
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.xxLarge)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
        .navigationTitle("Motor Health")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func assessmentCard(
        title: String,
        subtitle: String,
        icon: String,
        badge: String,
        badgeColor: Color
    ) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(badgeColor)
            }
            
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(badgeColor)
                        .padding(.horizontal, DesignTokens.Spacing.small)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(badgeColor.opacity(0.12)))
                }
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignTokens.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        MotorHealthHomeView()
    }
}
