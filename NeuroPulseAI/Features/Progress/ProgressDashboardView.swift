//
//  ProgressDashboardView.swift
//  NeuroPulseAI
//
//  Visualizes historical motor assessment measurements using Swift Charts.
//

import SwiftUI
import Charts

public struct ProgressDashboardView: View {
    @ObservedObject private var store = MotorSessionStore.shared
    @State private var selectedTest: MotorTestType = .tapping
    @State private var selectedHand: String = "Right"
    
    public init() {}
    
    private var filteredRecords: [MotorSessionRecord] {
        store.records
            .filter { $0.testType == selectedTest && $0.testedHand == selectedHand }
            .sorted(by: { $0.date != $1.date ? $0.date < $1.date : $0.id.uuidString < $1.id.uuidString })
    }
    
    private var loggedAttemptsRecords: [MotorSessionRecord] {
        store.records
            .filter { $0.testType == selectedTest && $0.testedHand == selectedHand }
            .sorted(by: { $0.date != $1.date ? $0.date > $1.date : $0.id.uuidString > $1.id.uuidString })
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Measurement Progress")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                .padding(.top, DesignTokens.Spacing.small)
                
                // Filter Segment Controls
                VStack(spacing: DesignTokens.Spacing.small) {
                    Picker("Test Type", selection: $selectedTest) {
                        ForEach(MotorTestType.allCases, id: \.self) { test in
                            Text(test.rawValue).tag(test)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Hand", selection: $selectedHand) {
                        Text("Right Hand").tag("Right")
                        Text("Left Hand").tag("Left")
                    }
                    .pickerStyle(.segmented)
                }
                
                // Chart Card
                chartCardSection
                
                // Session History List
                historyListSection
                
                // Demo Data Helper
                demoDataHelperSection
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.xxLarge)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Chart Section
    
    private var chartCardSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedTest == .tapping ? "Cadence (Hz)" : "RMSE Deviation (%)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text(selectedTest == .tapping ? "Higher reflects faster tapping" : "Lower reflects closer path tracing")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            if filteredRecords.isEmpty {
                VStack(spacing: DesignTokens.Spacing.medium) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text("No records found for \(selectedTest.rawValue) (\(selectedHand) Hand).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(filteredRecords) { item in
                        AreaMark(
                            x: .value("Date", item.date),
                            y: .value("Value", item.primaryScoreValue)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    (selectedTest == .tapping ? Color.NeuroPulse.motorPrimary : Color.NeuroPulse.motorSecondary).opacity(0.25),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Value", item.primaryScoreValue)
                        )
                        .foregroundStyle(selectedTest == .tapping ? Color.NeuroPulse.motorPrimary : Color.NeuroPulse.motorSecondary)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        
                        PointMark(
                            x: .value("Date", item.date),
                            y: .value("Value", item.primaryScoreValue)
                        )
                        .foregroundStyle(selectedTest == .tapping ? Color.NeuroPulse.motorPrimary : Color.NeuroPulse.motorSecondary)
                        .symbolSize(40)
                    }
                }
                .frame(height: 220)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding(DesignTokens.Spacing.large)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
        )
    }
    
    // MARK: - History List Section
    
    private var historyListSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
            Text("Logged Attempts")
                .font(.headline)
                .foregroundStyle(.primary)
            
            if filteredRecords.isEmpty {
                Text("Complete a session to log and view results.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: DesignTokens.Spacing.small) {
                    ForEach(loggedAttemptsRecords) { record in
                        HStack(spacing: DesignTokens.Spacing.medium) {
                            Circle()
                                .fill(record.qualityStatus == .valid ? Color.NeuroPulse.success : Color.NeuroPulse.warning)
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    if record.isSampleData {
                                        Text("Sample Demo")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(Color.NeuroPulse.info)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Capsule().fill(Color.NeuroPulse.info.opacity(0.12)))
                                    }
                                }
                                
                                Text(recordSubtitle(for: record))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(record.primaryScoreLabel)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(selectedTest == .tapping ? Color.NeuroPulse.motorPrimary : Color.NeuroPulse.motorSecondary)
                        }
                        .padding(DesignTokens.Spacing.medium)
                        .background(Color.NeuroPulse.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                        )
                    }
                }
            }
        }
    }
    
    private func recordSubtitle(for record: MotorSessionRecord) -> String {
        var subText = "\(record.secondaryScoreLabel) • \(record.qualityStatus.rawValue)"
        if let dev = record.meanCenterDeviationPoints {
            subText += String(format: " • %.1f pt dev", dev)
        }
        return subText
    }
    
    // MARK: - Demo Data & Export Helpers
    
    private var demoDataHelperSection: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            // User-initiated CSV Export
            if !store.records.isEmpty, let exportURL = SessionExportService.exportTemporaryCSVFile(from: store.records) {
                ShareLink(
                    item: exportURL,
                    preview: SharePreview("NeuroPulse AI Sessions CSV", image: Image(systemName: "doc.text.fill"))
                ) {
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Session History (CSV)")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.NeuroPulse.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                            .stroke(Color.NeuroPulse.brandTeal.opacity(0.4), lineWidth: 0.75)
                    )
                }
            }
            
            VStack(spacing: DesignTokens.Spacing.small) {
                Button {
                    store.loadSampleDemonstrationData()
                } label: {
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: "plus.circle")
                        Text("Load Sample Trend Data")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                }
                
                if !store.records.isEmpty {
                    Button(role: .destructive) {
                        store.clearAll()
                    } label: {
                        Text("Clear All Sessions")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.small)
    }
}

#Preview {
    NavigationStack {
        ProgressDashboardView()
    }
}
