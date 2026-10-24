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
                VStack(alignment: .leading, spacing: 4) {
                    Text("Motor Health")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                .padding(.top, DesignTokens.Spacing.small)

                // Active Test Modules Section
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                    Text("Available Assessments")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    // Finger Tapping Card
                    NavigationLink {
                        TappingTestView()
                    } label: {
                        assessmentCard(
                            title: "Finger-Tapping Test",
                            icon: "hand.point.up.left.fill",
                            badge: "Protocol v1",
                            badgeColor: Color.NeuroPulse.motorPrimary
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Spiral Tracing Card
                    NavigationLink {
                        SpiralTracingView()
                    } label: {
                        assessmentCard(
                            title: "Spiral-Tracing Test",
                            icon: "scribble.variable",
                            badge: "Geometry v1",
                            badgeColor: Color.NeuroPulse.motorSecondary
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Baseline & History Preview Card
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                    Text("Session History & Trends")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    NavigationLink {
                        SavedRecordsView()
                    } label: {
                        HStack(spacing: DesignTokens.Spacing.medium) {
                            ZStack {
                                Circle()
                                    .fill(Color.NeuroPulse.motorPrimary.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.NeuroPulse.motorPrimary)
                            }

                            Text("Saved Assessment Records")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.NeuroPulse.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink {
                        ProgressDashboardView()
                    } label: {
                        HStack(spacing: DesignTokens.Spacing.medium) {
                            ZStack {
                                Circle()
                                    .fill(Color.NeuroPulse.brandTeal.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "chart.xyaxis.line")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                            }

                            Text("Measurement Trends & Progress")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.NeuroPulse.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
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
        icon: String,
        badge: String,
        badgeColor: Color
    ) -> some View {
        HStack(spacing: DesignTokens.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(badgeColor)
            }

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            Text(badge)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(badgeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(badgeColor.opacity(0.12)))

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
        )
    }
}

#Preview {
    NavigationStack {
        MotorHealthHomeView()
    }
}
