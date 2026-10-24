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
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
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
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        ForEach(recommendationService.recommendations) { item in
                            recommendationCard(item)
                        }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.vertical, DesignTokens.Spacing.large)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
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
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                Text("Your Insights")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                modeBadge
            }
            
            Text(recommendationService.statusMessage.isEmpty
                 ? "Explainable suggestions based on your activity patterns."
                 : recommendationService.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    private var modeBadge: some View {
        let isCloud = authManager.currentMode == .authenticated && consentManager.isPersonalizationConsented
        return HStack(spacing: 4) {
            Image(systemName: isCloud ? "cloud.fill" : "iphone")
                .font(.system(size: 11))
            Text(isCloud ? "Cloud Personalized" : "Local Guidance")
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(isCloud ? Color.NeuroPulse.brandTeal : Color.NeuroPulse.motorPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isCloud ? Color.NeuroPulse.brandTeal.opacity(0.12) : Color.NeuroPulse.motorPrimary.opacity(0.12))
        )
    }
    
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView("Analyzing authorized activity trends...")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, DesignTokens.Spacing.large)
    }
    
    private var insufficientDataCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack(spacing: DesignTokens.Spacing.small) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                Text("More Data Needed For Trends")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            Text("Trend analysis requires repeat sessions to observe natural motor pacing and relaxation recovery. Complete at least 2 motor assessments or wellness sessions to receive data-driven insights.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.NeuroPulse.brandTeal.opacity(0.35), lineWidth: 0.75)
        )
    }
    
    private func recommendationCard(_ item: RecommendationUIModel) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(categoryColor(item.category).opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: categoryIcon(item.category))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(categoryColor(item.category))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(item.category.capitalized)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(categoryColor(item.category))
                }
                
                Spacer()
            }
            
            Text(item.description)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
                .padding(.vertical, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.NeuroPulse.brandTeal)
                    Text("Why you're seeing this")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                
                Text(item.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
    
    private func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "cadence", "rhythm":
            return Color.NeuroPulse.motorPrimary
        case "tracing":
            return Color.NeuroPulse.motorSecondary
        case "wellness":
            return Color.NeuroPulse.mindEasePrimary
        default:
            return Color.NeuroPulse.brandTeal
        }
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
