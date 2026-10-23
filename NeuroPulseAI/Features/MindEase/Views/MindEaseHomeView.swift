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
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: "wind")
                            .font(.headline)
                            .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                        
                        Text("MINDFUL WELLNESS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .tracking(1.2)
                            .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                    }
                    
                    Text("MindEase")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Paced breathing, meditation, and unscored mindful interaction for personal relaxation.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
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
                            subtitle: "Animated visual pacing for calming, balanced breathwork. Fully interruptible.",
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
                            subtitle: "A short, self-directed stillness session to reduce stress and reset focus.",
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
                            subtitle: "An unscored, therapeutic tactile exercise separate from motor evaluations.",
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
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                        }
                    }
                    
                    if store.records.isEmpty {
                        Text("No wellness sessions recorded yet. Completed breathing or stillness sessions will appear here.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(DesignTokens.Spacing.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.NeuroPulse.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
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
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(Int(record.durationSeconds))s")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                                }
                                .padding(DesignTokens.Spacing.medium)
                                .background(Color.NeuroPulse.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                                        .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                
                // Separate Wellness Data Note
                HStack(spacing: DesignTokens.Spacing.medium) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                    
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                        Text("Separate Wellness Records")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("MindEase check-ins and session times are kept strictly separate from motor-health assessment data.")
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
                
                // Disclaimer Banner
                DisclaimerBanner()
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
        MindEaseHomeView()
    }
}
