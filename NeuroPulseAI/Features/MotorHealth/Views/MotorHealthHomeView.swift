//
//  MotorHealthHomeView.swift
//  NeuroPulseAI
//
//  Motor Health landing screen in Soft Neo-Brutalist design language.
//  Flat pastel fills, 2pt ink outlines, hard offset shadows (3, 3),
//  white outlined icon tiles, and rounded geometric typography.
//

import SwiftUI

public struct MotorHealthHomeView: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header Intro
                VStack(alignment: .leading, spacing: 4) {
                    Text("Motor Health")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)

                    Text("Fine-motor dexterity, cadence timing, and movement accuracy")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)
                }
                .padding(.top, 8)

                // Active Test Modules Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("Available Assessments")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)

                    // Finger Tapping Card (Lavender fill)
                    NavigationLink {
                        TappingTestView()
                    } label: {
                        assessmentCard(
                            title: "Finger-Tapping Test",
                            subtitle: "15-second alternating target protocol",
                            icon: "hand.point.up.left.fill",
                            badge: "Protocol v1",
                            fill: Color.NeoBrutal.lavender
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Spiral Tracing Card (Mint fill)
                    NavigationLink {
                        SpiralTracingView()
                    } label: {
                        assessmentCard(
                            title: "Spiral-Tracing Test",
                            subtitle: "Continuous path tremor & trajectory curve",
                            icon: "scribble.variable",
                            badge: "Geometry v1",
                            fill: Color.NeoBrutal.mint
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Baseline & History Preview Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("Session History & Trends")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)

                    NavigationLink {
                        SavedRecordsView()
                    } label: {
                        HStack(spacing: 14) {
                            BrutalIconTile(
                                iconName: "clock.arrow.circlepath",
                                size: 44,
                                iconSize: 20,
                                cornerRadius: 12,
                                outlineWidth: 1.5,
                                bg: Color.NeoBrutal.lavender.opacity(0.35)
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Saved Assessment Records")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.NeoBrutal.ink)

                                Text("Inspect previous alternating tapping deviations")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundStyle(Color.NeoBrutal.mutedText)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.NeoBrutal.ink)
                        }
                        .padding(16)
                        .brutalCard(cornerRadius: 18, fill: .white, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink {
                        ProgressDashboardView()
                    } label: {
                        HStack(spacing: 14) {
                            BrutalIconTile(
                                iconName: "chart.xyaxis.line",
                                size: 44,
                                iconSize: 20,
                                cornerRadius: 12,
                                outlineWidth: 1.5,
                                bg: Color.NeoBrutal.mint.opacity(0.35)
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Measurement Trends & Progress")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.NeoBrutal.ink)

                                Text("Review cadence trends and RMSE stability curves")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundStyle(Color.NeoBrutal.mutedText)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.NeoBrutal.ink)
                        }
                        .padding(16)
                        .brutalCard(cornerRadius: 18, fill: .white, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Motor Health")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func assessmentCard(
        title: String,
        subtitle: String,
        icon: String,
        badge: String,
        fill: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                BrutalIconTile(
                    iconName: icon,
                    size: 48,
                    iconSize: 22,
                    cornerRadius: 14,
                    outlineWidth: 2,
                    bg: .white
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink.opacity(0.8))
                        .lineLimit(1)
                }

                Spacer()

                BrutalBadge(badge, style: .custom(bg: .white, fg: Color.NeoBrutal.ink))
            }

            // Bottom action row
            HStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                    Text("Start Test")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.NeoBrutal.ink)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.NeoBrutal.ink)
                            .offset(x: 2, y: 2)
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white)
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.NeoBrutal.ink, lineWidth: 1.5)
                    }
                )
            }
        }
        .padding(18)
        .brutalCard(cornerRadius: 22, fill: fill, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
    }
}

#Preview {
    NavigationStack {
        MotorHealthHomeView()
    }
}
