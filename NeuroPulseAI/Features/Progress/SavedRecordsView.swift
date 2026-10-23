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
                
                // Filter Picker
                Picker("Activity Category", selection: $selectedFilter) {
                    ForEach(ActivityHistoryFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                
                // Records List or Empty State
                if unifiedItems.isEmpty {
                    emptyStateSection
                } else {
                    recordsListSection
                }
                
                // Export & Management
                exportAndManagementSection
                
                // Disclaimer Banner
                DisclaimerBanner()
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.xxLarge)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
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
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack(spacing: DesignTokens.Spacing.small) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                Text(authManager.currentMode == .authenticated
                     ? "ACCOUNT HISTORY • \(authManager.currentUser?.email ?? "USER")"
                     : "LOCAL ON-DEVICE HISTORY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(1.2)
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
            }
            
            Text("Activity History")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(authManager.currentMode == .authenticated
                 ? "Review your account's completed fine-motor assessments and MindEase sessions."
                 : "Review completed Motor Health assessments and MindEase wellness moments stored locally on this device.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, DesignTokens.Spacing.small)
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(Color.NeuroPulse.brandTeal.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "tray.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
            }
            
            Text("No Saved Records Yet")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Complete a Finger-Tapping or Spiral-Tracing assessment, or take a peaceful breathing session. Completed sessions will automatically save and appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignTokens.Spacing.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xxLarge)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
    }
    
    private var recordsListSection: some View {
        VStack(spacing: DesignTokens.Spacing.small) {
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
        HStack(alignment: .top, spacing: DesignTokens.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(item.iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: item.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(item.iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if item.isSampleData {
                        Text("Demo")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.NeuroPulse.info))
                    }
                    
                    Spacer()
                    
                    Text(item.primaryScore)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(item.iconColor)
                }
                
                HStack {
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(item.isSuccessStatus ? Color.NeuroPulse.success : Color.NeuroPulse.warning)
                        .frame(width: 6, height: 6)
                    
                    Text(item.statusLabel)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(item.isSuccessStatus ? Color.NeuroPulse.success : Color.NeuroPulse.warning)
                    
                    Spacer()
                    
                    Text("Details")
                        .font(.caption2)
                        .foregroundStyle(Color.NeuroPulse.brandTeal)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)
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
    
    // MARK: - Export and Management
    
    private var exportAndManagementSection: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            // User-initiated CSV Export
            if !motorStore.records.isEmpty, let exportURL = SessionExportService.exportTemporaryCSVFile(from: motorStore.records) {
                ShareLink(
                    item: exportURL,
                    preview: SharePreview("NeuroPulse AI Sessions CSV", image: Image(systemName: "doc.text.fill"))
                ) {
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Motor Sessions (CSV)")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.medium)
                    .background(Color.NeuroPulse.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                            .stroke(Color.NeuroPulse.brandTeal.opacity(0.4), lineWidth: 1)
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
                    .font(.footnote)
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
                        .font(.footnote)
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
                    
                    DisclaimerBanner()
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
