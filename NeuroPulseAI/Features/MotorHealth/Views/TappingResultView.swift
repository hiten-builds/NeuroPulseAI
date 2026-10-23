//
//  TappingResultView.swift
//  NeuroPulseAI
//
//  Detailed review of finger-tapping metrics, rhythm consistency,
//  two-zone center deviation accuracy, and local persistence confirmation.
//

import SwiftUI

public struct TappingResultView: View {
    let metrics: TappingMetrics
    var onDismiss: (() -> Void)? = nil
    
    public init(metrics: TappingMetrics, onDismiss: (() -> Void)? = nil) {
        self.metrics = metrics
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                // Header & Quality Badge
                headerSection
                
                // Persistence Confirmation Banner
                saveConfirmationBanner
                
                // Center-Deviation & Target Accuracy Card
                centerDeviationSection
                
                // Primary Cadence Metrics Grid
                metricsGridSection
                
                // Rhythm & Fatigue Analysis
                rhythmSection
                
                // Quality Indicator Card
                qualitySection
                
                // Safety Disclaimer
                DisclaimerBanner()
                
                // Action Buttons
                Button {
                    onDismiss?()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.medium)
                        .background(Color.NeuroPulse.brandTeal)
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
                Text("TWO-ZONE FINGER TAPPING")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(1.2)
                    .foregroundStyle(Color.NeuroPulse.motorPrimary)
                
                Spacer()
                
                qualityBadge(metrics.qualityStatus)
            }
            
            Text("\(metrics.testedHand) Hand")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text("Duration: \(String(format: "%.1f", metrics.durationSeconds))s • Protocol v\(metrics.protocolVersion)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var saveConfirmationBanner: some View {
        HStack(spacing: DesignTokens.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(Color.NeuroPulse.success.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: "checkmark.seal.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color.NeuroPulse.success)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Saved to On-Device History")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text("Record is securely stored on this device and available in Activity History.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(DesignTokens.Spacing.medium)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(Color.NeuroPulse.success.opacity(0.35), lineWidth: 1)
        )
    }
    
    private var centerDeviationSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
            HStack {
                Text("Target Accuracy & Center Deviation")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "scope")
                    .font(.subheadline)
                    .foregroundStyle(Color.NeuroPulse.motorPrimary)
            }
            
            VStack(spacing: DesignTokens.Spacing.medium) {
                // Average Deviation Stat
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mean Center Deviation")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Average Euclidean offset from expected target center")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let dev = metrics.meanCenterDeviationPoints {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(String(format: "%.1f pt", dev))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.NeuroPulse.motorPrimary)
                            
                            if let norm = metrics.meanNormalizedCenterDeviationPercent {
                                Text(String(format: "%.1f%% radius", norm))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Text("N/A")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // Alternation Accuracy
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alternation Accuracy")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Correct alternating taps / total attempts")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let acc = metrics.alternationAccuracyPercent {
                        Text(String(format: "%.1f%%", acc))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(acc >= 80.0 ? Color.NeuroPulse.success : Color.NeuroPulse.warning)
                    } else {
                        Text("N/A")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // Breakdown numbers
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Attempts Breakdown")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(metrics.correctAlternatingTaps) correct • \(metrics.incorrectTargetAttempts) wrong target • \(metrics.missedTargetAttempts) missed")
                            .font(.footnote)
                            .fontWeight(.medium)
                    }
                    Spacer()
                }
                
                // Informational note
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("Target accuracy is an exploratory geometric measurement in SwiftUI points. A lower deviation indicates touches landing closer to target centers.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 2)
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
    
    private var metricsGridSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignTokens.Spacing.medium) {
            metricCard(
                title: "Cadence",
                value: String(format: "%.2f", metrics.cadenceHz),
                unit: "taps / sec (Hz)",
                icon: "speedometer"
            )
            
            metricCard(
                title: "Valid Alternations",
                value: "\(metrics.tapCount)",
                unit: "accepted taps",
                icon: "hand.tap.fill"
            )
            
            metricCard(
                title: "Mean Interval",
                value: String(format: "%.0f", metrics.meanIntervalMs),
                unit: "milliseconds",
                icon: "clock.arrow.circlepath"
            )
            
            metricCard(
                title: "Median Interval",
                value: String(format: "%.0f", metrics.medianIntervalMs),
                unit: "milliseconds",
                icon: "chart.bar.fill"
            )
        }
    }
    
    private var rhythmSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
            Text("Rhythm & Stability")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(spacing: DesignTokens.Spacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Timing Variability (CV)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Lower variability reflects higher rhythmic regularity")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "%.1f%%", metrics.coefficientOfVariationPercent))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.NeuroPulse.motorPrimary)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fatigue Trend (2nd / 1st Half)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Values close to 1.0 indicate sustained cadence")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "%.2f", metrics.fatigueRatio))
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
                    .foregroundStyle(Color.NeuroPulse.motorPrimary)
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
        TappingResultView(
            metrics: TappingMetrics(
                testedHand: "Right",
                durationSeconds: 15.0,
                tapCount: 88,
                cadenceHz: 5.86,
                meanIntervalMs: 170.4,
                medianIntervalMs: 168.0,
                intervalStdDevMs: 24.2,
                coefficientOfVariationPercent: 14.2,
                fatigueRatio: 0.94,
                meanCenterDeviationPoints: 5.4,
                meanNormalizedCenterDeviationPercent: 16.8,
                medianCenterDeviationPoints: 4.8,
                maxCenterDeviationPoints: 12.1,
                totalAttempts: 92,
                correctAlternatingTaps: 88,
                incorrectTargetAttempts: 3,
                missedTargetAttempts: 1,
                alternationAccuracyPercent: 95.7,
                qualityStatus: .valid,
                qualityExplanation: "Session meets quality criteria with stable pacing and full duration."
            )
        )
    }
}
