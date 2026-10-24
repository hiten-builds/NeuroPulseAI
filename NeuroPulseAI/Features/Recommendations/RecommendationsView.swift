//
//  RecommendationsView.swift
//  NeuroPulseAI
//
//  Displays explainable recommendations derived from either:
//  - Consented account assessment trends via FastAPI backend (Mode A)
//  - Deterministic on-device local baseline rules (Mode B)
//  Strictly non-diagnostic and fully explainable.
//

import SwiftUI

public struct RecommendationsView: View {
    @ObservedObject private var recommendationService = RecommendationService.shared
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var consentManager = ConsentManager.shared
    @ObservedObject private var syncService = SyncService.shared

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Header & Mode Badge
                headerSection

                // MARK: - Insufficient Data or Loading State
                if recommendationService.isLoading {
                    loadingView
                } else if !recommendationService.hasSufficientData {
                    insufficientDataCard
                }

                // MARK: - Recommendations List
                if !recommendationService.recommendations.isEmpty {
                    VStack(spacing: 14) {
                        ForEach(recommendationService.recommendations) { item in
                            recommendationCard(item)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Recommendations")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await syncService.syncEligibleSessions()
                        await recommendationService.loadRecommendations()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.NeoBrutal.ink)
                }
            }
        }
        .task {
            await syncService.syncEligibleSessions()
            await recommendationService.loadRecommendations()
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Your Insights")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)

                Spacer()

                modeBadge
            }

            Text(recommendationService.statusMessage.isEmpty
                 ? "Explainable suggestions based on your activity patterns."
                 : recommendationService.statusMessage)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)
        }
    }

    private var modeBadge: some View {
        let isCloud = authManager.currentMode == .authenticated && consentManager.isPersonalizationConsented
        return BrutalBadge(
            isCloud ? "Cloud Personalized" : "Local Guidance",
            style: isCloud ? .inProgress : .pending
        )
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView("Analyzing authorized activity trends...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)
            Spacer()
        }
        .padding(.vertical, 24)
    }

    private var insufficientDataCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                BrutalIconTile(
                    iconName: "chart.line.uptrend.xyaxis",
                    size: 38,
                    iconSize: 18,
                    cornerRadius: 10,
                    outlineWidth: 1.5,
                    bg: Color.NeoBrutal.peach
                )
                Text("More Data Needed For Trends")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.ink)
            }

            Text("Trend analysis requires repeat sessions to observe natural motor pacing and relaxation recovery. Complete at least 2 motor assessments or wellness sessions to receive data-driven insights.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink.opacity(0.8))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .brutalCard(cornerRadius: 20, fill: Color.NeoBrutal.peach.opacity(0.3), outlineWidth: 2, hasShadow: true, shadowOffset: 3)
    }

    private func recommendationCard(_ item: RecommendationUIModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                BrutalIconTile(
                    iconName: categoryIcon(item.category),
                    size: 42,
                    iconSize: 20,
                    cornerRadius: 12,
                    outlineWidth: 1.5,
                    bg: pastelForCategory(item.category)
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)

                    BrutalBadge(item.category.capitalized, style: .custom(bg: pastelForCategory(item.category), fg: Color.NeoBrutal.ink))
                }

                Spacer()
            }

            Text(item.description)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)

            // Rational / Explanation Tag
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.NeoBrutal.mutedText)
                    .padding(.top, 1)

                Text(item.explanation)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.mutedText)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.NeoBrutal.ink.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(18)
        .brutalCard(cornerRadius: 20, fill: .white, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
    }

    private func pastelForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "cadence", "rhythm", "motor":
            return Color.NeoBrutal.lavender
        case "wellness":
            return Color.NeoBrutal.mint
        default:
            return Color.NeoBrutal.peach
        }
    }

    private func categoryColor(_ category: String) -> Color {
        pastelForCategory(category)
    }

    private func categoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "cadence", "rhythm":
            return "hand.tap.fill"
        case "tracing":
            return "scribble.variable"
        case "wellness":
            return "wind"
        default:
            return "sparkles"
        }
    }
}
