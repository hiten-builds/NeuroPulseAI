//
//  MindEaseHomeView.swift
//  NeuroPulseAI
//
//  MindEase wellness landing screen in Soft Neo-Brutalist design language.
//  Flat pastel fills (Mint #D3F7B4, Lavender #D4C6F7, Peach #F8D89A),
//  2pt ink outlines, hard offset shadows (3, 3), and rounded geometric typography.
//

import SwiftUI

public struct MindEaseHomeView: View {
    @ObservedObject private var store = WellnessSessionStore.shared

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header Intro
                VStack(alignment: .leading, spacing: 4) {
                    Text("MindEase")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)

                    Text("Paced breathwork, quiet pause, and soothing mindful tactile tracing")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)
                }
                .padding(.top, 8)

                // Activities Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("Wellness Activities")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)

                    // Guided Breathing Card (Mint)
                    NavigationLink {
                        BreathingSessionView()
                    } label: {
                        activityCard(
                            title: "Guided Breathing",
                            subtitle: "Animated visual pacing for balanced rhythm",
                            icon: "circle.circle",
                            badge: "Visual Pacer",
                            fill: Color.NeoBrutal.mint
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Mindful Meditation Card (Lavender)
                    NavigationLink {
                        MindfulnessMeditationView()
                    } label: {
                        activityCard(
                            title: "Mindfulness Pause",
                            subtitle: "Short self-directed stillness to reset focus",
                            icon: "sparkles",
                            badge: "Quiet Focus",
                            fill: Color.NeoBrutal.lavender
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Mindful Tracing Card (Peach)
                    NavigationLink {
                        MindfulTracingView()
                    } label: {
                        activityCard(
                            title: "Mindful Tracing",
                            subtitle: "Tactile unscored flow for relaxation",
                            icon: "leaf.fill",
                            badge: "Unscored",
                            fill: Color.NeoBrutal.peach
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Recent Wellness Sessions List
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Recent Peaceful Moments")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.ink)
                        Spacer()
                        NavigationLink {
                            SavedRecordsView()
                        } label: {
                            HStack(spacing: 4) {
                                Text("All History")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.ink)
                        }
                    }

                    if store.records.isEmpty {
                        Text("No wellness sessions recorded yet.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.mutedText)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .brutalRow(cornerRadius: 16, fill: .white, outlineWidth: 1.5)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(store.records.prefix(4)) { record in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(record.activityType.rawValue)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.NeoBrutal.ink)
                                        Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.system(size: 13, weight: .regular, design: .rounded))
                                            .foregroundStyle(Color.NeoBrutal.mutedText)
                                    }

                                    Spacer()

                                    BrutalBadge("\(Int(record.durationSeconds))s", style: .inProgress)
                                }
                                .padding(16)
                                .brutalRow(cornerRadius: 16, fill: .white, outlineWidth: 1.5)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("MindEase")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func activityCard(
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
                    Text("Begin")
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
        MindEaseHomeView()
    }
}
