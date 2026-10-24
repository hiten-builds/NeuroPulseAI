//
//  MindEaseHomeView.swift
//  NeuroPulseAI
//
//  MindEase feature landing screen presenting breathing exercises and mindfulness sessions.
//

import SwiftUI

public struct MindEaseHomeView: View {
    @ObservedObject private var store = WellnessSessionStore.shared

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                // Header Intro
                VStack(alignment: .leading, spacing: 4) {
                    Text("MindEase")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                .padding(.top, DesignTokens.Spacing.small)

                // Activities Section
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                    Text("Wellness Activities")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    // Guided Breathing Card
                    NavigationLink {
                        BreathingSessionView()
                    } label: {
                        activityCard(
                            title: "Guided Breathing",
                            icon: "circle.circle",
                            badge: "Visual Pacer",
                            badgeColor: Color.NeuroPulse.mindEasePrimary
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Mindful Meditation Card
                    NavigationLink {
                        MindfulnessMeditationView()
                    } label: {
                        activityCard(
                            title: "Mindfulness Pause",
                            icon: "sparkles",
                            badge: "Quiet Focus",
                            badgeColor: Color.NeuroPulse.mindEaseSecondary
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Mindful Tracing Card
                    NavigationLink {
                        MindfulTracingView()
                    } label: {
                        activityCard(
                            title: "Mindful Tracing",
                            icon: "leaf.fill",
                            badge: "Unscored",
                            badgeColor: Color.NeuroPulse.brandTeal
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Recent Wellness Sessions List
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                    HStack {
                        Text("Recent Peaceful Moments")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                        NavigationLink {
                            SavedRecordsView()
                        } label: {
                            HStack(spacing: 4) {
                                Text("All History")
                                Image(systemName: "chevron.right")
                            }
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                        }
                    }

                    if store.records.isEmpty {
                        Text("No wellness sessions recorded yet.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.NeuroPulse.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                            )
                    } else {
                        VStack(spacing: DesignTokens.Spacing.small) {
                            ForEach(store.records.prefix(4)) { record in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(record.activityType.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Text("\(Int(record.durationSeconds))s")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                                }
                                .padding(16)
                                .background(Color.NeuroPulse.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.xxLarge)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
        .navigationTitle("MindEase")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func activityCard(
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
        MindEaseHomeView()
    }
}
