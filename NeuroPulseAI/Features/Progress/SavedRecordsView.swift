//
//  SavedRecordsView.swift
//  NeuroPulseAI
//
//  Comprehensive local activity history screen displaying all saved Motor Health
//  assessments and MindEase wellness sessions with filtering, detail review, and CSV export.
//

import SwiftUI

public enum ActivityHistoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case motor = "Motor Health"
    case wellness = "MindEase"

    public var id: String { rawValue }
}

public struct UnifiedActivityItem: Identifiable {
    public let id: String
    public let date: Date
    public let category: String
    public let title: String
    public let subtitle: String
    public let iconName: String
    public let iconColor: Color
    public let durationSeconds: Double
    public let primaryScore: String
    public let secondaryScore: String
    public let statusLabel: String
    public let isSuccessStatus: Bool
    public let isSampleData: Bool

    // Detailed metadata for inspection sheet
    public let testedHand: String?
    public let cadenceHz: Double?
    public let meanDeviationPoints: Double?
    public let normalizedDeviationPercent: Double?
    public let alternationAccuracy: Double?
    public let qualityExplanation: String?
    public let ratingBefore: Int?
    public let ratingAfter: Int?
}

public struct SavedRecordsView: View {
    @ObservedObject private var motorStore = MotorSessionStore.shared
    @ObservedObject private var wellnessStore = WellnessSessionStore.shared
    @ObservedObject private var authManager = AuthManager.shared

    @State private var selectedFilter: ActivityHistoryFilter = .all
    @State private var selectedRecordForDetail: UnifiedActivityItem? = nil
    @State private var showClearConfirmation: Bool = false

    public init() {}

    private var unifiedItems: [UnifiedActivityItem] {
        var items: [UnifiedActivityItem] = []

        // 1. Motor Records
        if selectedFilter == .all || selectedFilter == .motor {
            for m in motorStore.records {
                let isSuccess = m.qualityStatus == .valid

                var subtitleParts: [String] = []
                subtitleParts.append("\(m.testedHand) Hand")
                if let dev = m.meanCenterDeviationPoints {
                    subtitleParts.append(String(format: "%.1f pt dev", dev))
                }
                if let acc = m.alternationAccuracyPercent {
                    subtitleParts.append(String(format: "%.0f%% acc", acc))
                }

                let item = UnifiedActivityItem(
                    id: "motor_\(m.id.uuidString)",
                    date: m.date,
                    category: "Motor Health",
                    title: m.testType.rawValue,
                    subtitle: subtitleParts.joined(separator: " • "),
                    iconName: m.testType == .tapping ? "hand.point.up.left.fill" : "scribble.variable",
                    iconColor: m.testType == .tapping ? Color.NeuroPulse.motorPrimary : Color.NeuroPulse.motorSecondary,
                    durationSeconds: m.durationSeconds,
                    primaryScore: m.primaryScoreLabel,
                    secondaryScore: m.secondaryScoreLabel,
                    statusLabel: m.qualityStatus.rawValue,
                    isSuccessStatus: isSuccess,
                    isSampleData: m.isSampleData,
                    testedHand: m.testedHand,
                    cadenceHz: m.testType == .tapping ? m.primaryScoreValue : nil,
                    meanDeviationPoints: m.meanCenterDeviationPoints,
                    normalizedDeviationPercent: m.meanNormalizedCenterDeviationPercent,
                    alternationAccuracy: m.alternationAccuracyPercent,
                    qualityExplanation: m.qualityStatus == .valid ? "Meets protocol quality criteria." : "Session had quality limitations.",
                    ratingBefore: nil,
                    ratingAfter: nil
                )
                items.append(item)
            }
        }

        // 2. Wellness Records
        if selectedFilter == .all || selectedFilter == .wellness {
            for w in wellnessStore.records {
                let isSuccess = w.completionStatus == "Completed"

                var subtitleParts: [String] = []
                if let before = w.ratingBefore, let after = w.ratingAfter {
                    subtitleParts.append("Rating: \(before) → \(after)")
                } else if let rating = w.ratingAfter ?? w.ratingBefore {
                    subtitleParts.append("Rating: \(rating)/5")
                }

                let icon: String
                let color: Color
                switch w.activityType {
                case .breathing:
                    icon = "circle.circle"
                    color = Color.NeuroPulse.mindEasePrimary
                case .meditation:
                    icon = "sparkles"
                    color = Color.NeuroPulse.mindEaseSecondary
                case .mindfulTracing:
                    icon = "leaf.fill"
                    color = Color.NeuroPulse.brandTeal
                }

                let item = UnifiedActivityItem(
                    id: "wellness_\(w.id.uuidString)",
                    date: w.date,
                    category: "MindEase",
                    title: w.activityType.rawValue,
                    subtitle: subtitleParts.isEmpty ? "Mindful Activity" : subtitleParts.joined(separator: " • "),
                    iconName: icon,
                    iconColor: color,
                    durationSeconds: w.durationSeconds,
                    primaryScore: "\(Int(w.durationSeconds))s",
                    secondaryScore: w.completionStatus,
                    statusLabel: w.completionStatus,
                    isSuccessStatus: isSuccess,
                    isSampleData: false,
                    testedHand: nil,
                    cadenceHz: nil,
                    meanDeviationPoints: nil,
                    normalizedDeviationPercent: nil,
                    alternationAccuracy: nil,
                    qualityExplanation: isSuccess ? "Mindful exercise completed peacefully." : "Exercise ended early.",
                    ratingBefore: w.ratingBefore,
                    ratingAfter: w.ratingAfter
                )
                items.append(item)
            }
        }

        // Sort reverse chronological deterministically (newest first, id tie-breaker)
        return items.sorted(by: {
            if $0.date != $1.date {
                return $0.date > $1.date
            }
            return $0.id > $1.id
        })
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                // Header
                headerSection

                // Storage / Error banner
                if let err = motorStore.lastErrorMessage ?? wellnessStore.lastErrorMessage {
                    errorBanner(message: err)
                }

                // Filter Chips (Brutal style)
                HStack(spacing: 10) {
                    ForEach(ActivityHistoryFilter.allCases) { filter in
                        let isActive = selectedFilter == filter
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = filter
                            }
                        } label: {
                            Text(filter.rawValue)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.ink)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    ZStack {
                                        Capsule()
                                            .fill(Color.NeoBrutal.ink)
                                            .offset(x: 2, y: 2)
                                        Capsule()
                                            .fill(isActive ? Color.NeoBrutal.lavender : Color.white)
                                        Capsule()
                                            .stroke(Color.NeoBrutal.ink, lineWidth: 2)
                                    }
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // Records List or Empty State
                if unifiedItems.isEmpty {
                    emptyStateSection
                } else {
                    recordsListSection
                }

                // Export & Management
                exportAndManagementSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Saved Records")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedRecordForDetail) { record in
            recordDetailSheet(record)
        }
        .confirmationDialog("Clear All Records?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("Clear All Sessions", role: .destructive) {
                motorStore.clearAll()
                wellnessStore.clearAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete local sessions stored on this device.")
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Activity History")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)

            Text("Chronological record of completed assessments and wellness sessions")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)
        }
        .padding(.top, 8)
    }

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            BrutalIconTile(
                iconName: "tray.fill",
                size: 64,
                iconSize: 28,
                cornerRadius: 18,
                outlineWidth: 2,
                bg: Color.NeoBrutal.lavender
            )

            Text("No Saved Records Yet")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)

            Text("Completed assessments and wellness sessions will appear here.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.mutedText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .brutalCard(cornerRadius: 20, fill: .white, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
    }

    private var recordsListSection: some View {
        VStack(spacing: 10) {
            ForEach(unifiedItems) { item in
                Button {
                    selectedRecordForDetail = item
                } label: {
                    recordCard(item)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    @ViewBuilder
    private func recordCard(_ item: UnifiedActivityItem) -> some View {
        HStack(alignment: .center, spacing: 14) {
            BrutalIconTile(
                iconName: item.iconName,
                size: 44,
                iconSize: 20,
                cornerRadius: 12,
                outlineWidth: 1.5,
                bg: item.category == "Motor Health" ? Color.NeoBrutal.lavender.opacity(0.4) : Color.NeoBrutal.mint.opacity(0.4)
            )

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)

                    Spacer()

                    Text(item.primaryScore)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)
                }

                HStack {
                    Text(item.subtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)

                    Spacer()

                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)
                }

                HStack {
                    BrutalBadge(
                        item.statusLabel,
                        style: item.isSuccessStatus ? .inProgress : .pending
                    )

                    Spacer()

                    HStack(spacing: 4) {
                        Text("Details")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.NeoBrutal.ink)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.NeoBrutal.ink)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .brutalRow(cornerRadius: 16, fill: .white, outlineWidth: 1.5)
    }

    // MARK: - Export and Management

    private var exportAndManagementSection: some View {
        VStack(spacing: 14) {
            // User-initiated CSV Export
            if !motorStore.records.isEmpty, let exportURL = SessionExportService.exportTemporaryCSVFile(from: motorStore.records) {
                ShareLink(
                    item: exportURL,
                    preview: SharePreview("NeuroPulse AI Sessions CSV", image: Image(systemName: "doc.text.fill"))
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .bold))
                        Text("Export Motor Sessions (CSV)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color.NeoBrutal.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.NeoBrutal.ink)
                                .offset(x: 3, y: 3)
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.NeoBrutal.lavender)
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.NeoBrutal.ink, lineWidth: 2)
                        }
                    )
                }
            }

            HStack(spacing: DesignTokens.Spacing.large) {
                Button {
                    motorStore.load()
                    wellnessStore.load()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                }

                if !unifiedItems.isEmpty {
                    Button(role: .destructive) {
                        showClearConfirmation = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("Clear All")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignTokens.Spacing.small)
    }

    @ViewBuilder
    private func errorBanner(message: String) -> some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.NeuroPulse.warning)
            Text(message)
                .font(.caption)
                .foregroundStyle(.primary)
            Spacer()
            Button("Retry") {
                motorStore.load()
                wellnessStore.load()
            }
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(Color.NeuroPulse.brandTeal)
        }
        .padding(DesignTokens.Spacing.medium)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
    }

    // MARK: - Detail Sheet

    private func recordDetailSheet(_ record: UnifiedActivityItem) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    // Header card
                    HStack(spacing: DesignTokens.Spacing.medium) {
                        ZStack {
                            Circle()
                                .fill(record.iconColor.opacity(0.15))
                                .frame(width: 52, height: 52)
                            Image(systemName: record.iconName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(record.iconColor)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(record.title)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("\(record.category) • \(record.date.formatted(date: .complete, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(DesignTokens.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.NeuroPulse.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))

                    // Metrics Breakdown
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                        Text("Session Metrics")
                            .font(.headline)

                        detailRow(title: "Duration", value: String(format: "%.1fs", record.durationSeconds))
                        detailRow(title: "Status", value: record.statusLabel)

                        if let hand = record.testedHand {
                            detailRow(title: "Tested Hand", value: "\(hand) Hand")
                        }

                        if let cadence = record.cadenceHz {
                            detailRow(title: "Cadence", value: String(format: "%.2f Hz", cadence))
                        }

                        if let dev = record.meanDeviationPoints {
                            detailRow(title: "Mean Center Deviation", value: String(format: "%.1f pt", dev))
                        }

                        if let norm = record.normalizedDeviationPercent {
                            detailRow(title: "Normalized Deviation", value: String(format: "%.1f%% radius", norm))
                        }

                        if let acc = record.alternationAccuracy {
                            detailRow(title: "Alternation Accuracy", value: String(format: "%.1f%%", acc))
                        }

                        if let before = record.ratingBefore {
                            detailRow(title: "Check-in Before", value: "\(before) / 5")
                        }
                        if let after = record.ratingAfter {
                            detailRow(title: "Check-in After", value: "\(after) / 5")
                        }
                    }
                    .padding(DesignTokens.Spacing.medium)
                    .background(Color.NeuroPulse.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))

                    // Quality / Explanation
                    if let expl = record.qualityExplanation {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                            Text("Quality Notes")
                                .font(.headline)
                            Text(expl)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(DesignTokens.Spacing.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.NeuroPulse.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                    }
                }
                .padding(DesignTokens.Spacing.large)
            }
            .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedRecordForDetail = nil
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        Divider()
    }
}

#Preview {
    NavigationStack {
        SavedRecordsView()
    }
}
