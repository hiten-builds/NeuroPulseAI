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
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Measurement Progress")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)

                    Text("Historical trend analysis across repeated assessment attempts")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)
                }
                .padding(.top, 8)

                // Filter Segment Controls
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        ForEach(MotorTestType.allCases, id: \.self) { test in
                            let isActive = selectedTest == test
                            Button {
                                selectedTest = test
                            } label: {
                                Text(test.rawValue)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.NeoBrutal.ink)
                                    .frame(maxWidth: .infinity)
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

                    HStack(spacing: 8) {
                        ForEach(["Right", "Left"], id: \.self) { hand in
                            let isActive = selectedHand == hand
                            Button {
                                selectedHand = hand
                            } label: {
                                Text("\(hand) Hand")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.NeoBrutal.ink)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 7)
                                    .background(
                                        ZStack {
                                            Capsule()
                                                .fill(Color.NeoBrutal.ink)
                                                .offset(x: 2, y: 2)
                                            Capsule()
                                                .fill(isActive ? Color.NeoBrutal.mint : Color.white)
                                            Capsule()
                                                .stroke(Color.NeoBrutal.ink, lineWidth: 2)
                                        }
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }

                // Chart Card
                chartCardSection

                // Session History List
                historyListSection

                // Demo Data Helper
                demoDataHelperSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Chart Section

    private var chartCardSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedTest == .tapping ? "Cadence (Hz)" : "RMSE Deviation (%)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.ink)
                    Text(selectedTest == .tapping ? "Higher reflects faster rhythm" : "Lower reflects closer path tracing")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)
                }
                Spacer()
                BrutalBadge(selectedTest.rawValue, style: .custom(bg: Color.NeoBrutal.lavender, fg: Color.NeoBrutal.ink))
            }

            if filteredRecords.isEmpty {
                VStack(spacing: 12) {
                    BrutalIconTile(
                        iconName: "chart.bar.xaxis",
                        size: 48,
                        iconSize: 22,
                        cornerRadius: 14,
                        outlineWidth: 1.5,
                        bg: Color.NeoBrutal.peach.opacity(0.3)
                    )
                    Text("No records found for \(selectedTest.rawValue) (\(selectedHand) Hand).")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.NeoBrutal.mutedText)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
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
                                    Color.NeoBrutal.lavender.opacity(0.55),
                                    Color.NeoBrutal.lavender.opacity(0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Value", item.primaryScoreValue)
                        )
                        .foregroundStyle(Color.NeoBrutal.ink)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                        PointMark(
                            x: .value("Date", item.date),
                            y: .value("Value", item.primaryScoreValue)
                        )
                        .foregroundStyle(Color.NeoBrutal.lavender)
                        .symbolSize(60)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(Color.NeoBrutal.ink.opacity(0.2))
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(Color.NeoBrutal.ink.opacity(0.2))
                        AxisValueLabel()
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                }
            }
        }
        .padding(18)
        .brutalCard(cornerRadius: 22, fill: .white, outlineWidth: 2, hasShadow: true, shadowOffset: 3)
    }

    // MARK: - History List Section

    private var historyListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Logged Attempts")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.NeoBrutal.ink)

            if filteredRecords.isEmpty {
                Text("Complete a session to log and view results.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.NeoBrutal.mutedText)
            } else {
                VStack(spacing: 10) {
                    ForEach(loggedAttemptsRecords) { record in
                        HStack(spacing: 12) {
                            BrutalBadge(
                                record.qualityStatus == .valid ? "Valid" : "Check",
                                style: record.qualityStatus == .valid ? .inProgress : .pending
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.NeoBrutal.ink)

                                    if record.isSampleData {
                                        BrutalBadge("Sample", style: .complete)
                                    }
                                }

                                Text(recordSubtitle(for: record))
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundStyle(Color.NeoBrutal.mutedText)
                            }

                            Spacer()

                            Text(record.primaryScoreLabel)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.NeoBrutal.ink)
                        }
                        .padding(14)
                        .brutalRow(cornerRadius: 16, fill: .white, outlineWidth: 1.5)
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
