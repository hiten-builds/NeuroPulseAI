//
//  SpiralResultView.swift
//  NeuroPulseAI
//
//  Detailed review of spiral tracing deviation error, length ratio, and path stability.
//

import SwiftUI

public struct SpiralResultView: View {
    let metrics: SpiralMetrics
    let userPoints: [SpiralPoint]
    var onDismiss: (() -> Void)? = nil
    
    private let referencePoints = SpiralFeatureCalculator.generateReferencePoints()
    
    public init(metrics: SpiralMetrics, userPoints: [SpiralPoint] = [], onDismiss: (() -> Void)? = nil) {
        self.metrics = metrics
        self.userPoints = userPoints
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                // Header & Quality Badge
                headerSection
                
                // Mini Trace Path Overlay Preview
                tracePreviewCard
                
                // Primary Metrics Grid
                metricsGridSection
                
                // Kinematics & Stability Card
                kinematicsSection
                
                // Quality Explanation
                qualitySection
                
                // Safety Disclaimer
                DisclaimerBanner()
                
                // Action Done Button
                Button {
                    onDismiss?()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.medium)
                        .background(Color.NeuroPulse.motorSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                }
                .padding(.top, DesignTokens.Spacing.small)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.vertical, DesignTokens.Spacing.large)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
        .navigationTitle("Assessment Results")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                Text("SPIRAL TRACING")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(1.2)
                    .foregroundStyle(Color.NeuroPulse.motorSecondary)
                
                Spacer()
                
                qualityBadge(metrics.qualityStatus)
            }
            
            Text("\(metrics.testedHand) Hand")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text("Duration: \(String(format: "%.1f", metrics.durationSeconds))s • Geometry Protocol v\(metrics.protocolVersion)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var tracePreviewCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            Text("Trace Overlay")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                ZStack {
                    Color.primary.opacity(0.03)
                    
                    // Reference Spiral (Dashed Gray/Blue)
                    Path { path in
                        guard let first = referencePoints.first else { return }
                        path.move(to: CGPoint(x: first.x * w, y: first.y * h))
                        for pt in referencePoints.dropFirst() {
                            path.addLine(to: CGPoint(x: pt.x * w, y: pt.y * h))
                        }
                    }
                    .stroke(
                        Color.primary.opacity(0.20),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 4])
                    )
                    
                    // User Trace (Vibrant Indigo/Cyan)
                    if !userPoints.isEmpty {
                        Path { path in
                            guard let first = userPoints.first else { return }
                            path.move(to: CGPoint(x: first.x * w, y: first.y * h))
                            for pt in userPoints.dropFirst() {
                                path.addLine(to: CGPoint(x: pt.x * w, y: pt.y * h))
                            }
                        }
                        .stroke(
                            Color.NeuroPulse.motorSecondary,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            }
            .frame(height: 200)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
            )
        }
    }
    
    private var metricsGridSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignTokens.Spacing.medium) {
            metricCard(
                title: "Path Deviation (RMSE)",
                value: String(format: "%.1f%%", metrics.rmsePercent),
                unit: "of canvas radius",
                icon: "arrow.triangle.swap"
            )
            
            metricCard(
                title: "Mean Deviation",
                value: String(format: "%.1f%%", metrics.meanDeviationPercent),
                unit: "radial error",
                icon: "circle.dotted"
            )
            
            metricCard(
                title: "Length Ratio",
                value: String(format: "%.2fx", metrics.pathLengthRatio),
                unit: "vs ideal spiral",
                icon: "ruler"
            )
            
            metricCard(
                title: "Speed Smoothness",
                value: String(format: "%.1f%%", metrics.speedVariabilityPercent),
                unit: "velocity CV",
                icon: "waveform.path"
            )
        }
    }
    
    private var kinematicsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
            Text("Kinematics & Smoothness")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(spacing: DesignTokens.Spacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Samples Captured")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Continuous coordinate positions")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(metrics.pointCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.NeuroPulse.motorPrimary)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Drawing Time")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Total active tracing duration")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "%.2fs", metrics.durationSeconds))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.NeuroPulse.motorSecondary)
                }
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
    
    private var qualitySection: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.medium) {
            Image(systemName: metrics.qualityStatus == .valid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(metrics.qualityStatus == .valid ? Color.NeuroPulse.success : Color.NeuroPulse.warning)
            
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                Text(metrics.qualityStatus.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(metrics.qualityExplanation)
                    .font(.caption)
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
    
    @ViewBuilder
    private func metricCard(title: String, value: String, unit: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Color.NeuroPulse.motorSecondary)
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
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
    
    @ViewBuilder
    private func qualityBadge(_ status: AssessmentQualityStatus) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status == .valid ? Color.NeuroPulse.success : Color.NeuroPulse.warning)
                .frame(width: 8, height: 8)
            
            Text(status.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, DesignTokens.Spacing.small)
        .padding(.vertical, DesignTokens.Spacing.xSmall)
        .background(Capsule().fill(Color.primary.opacity(0.06)))
    }
}

#Preview {
    NavigationStack {
        SpiralResultView(
            metrics: SpiralMetrics(
                testedHand: "Right",
                durationSeconds: 12.4,
                pointCount: 240,
                rmsePercent: 6.2,
                meanDeviationPercent: 4.8,
                pathLengthRatio: 1.04,
                speedVariabilityPercent: 22.4,
                qualityStatus: .valid,
                qualityExplanation: "Session meets quality criteria with complete trajectory and good path alignment."
            )
        )
    }
}
