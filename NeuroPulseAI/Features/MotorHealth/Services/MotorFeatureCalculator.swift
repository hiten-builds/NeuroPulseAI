//
//  MotorFeatureCalculator.swift
//  NeuroPulseAI
//
//  Pure mathematical calculation of fine-motor cadence, intervals, and rhythm consistency.
//

import Foundation

public struct MotorFeatureCalculator {
    public static let minimumTapsForValidSession: Int = 5
    
    /// Computes tapping metrics deterministically from an event sequence.
    public static func calculateMetrics(
        events: [TapEvent],
        plannedDuration: TimeInterval,
        actualDuration: TimeInterval,
        testedHand: String
    ) -> TappingMetrics {
        let tapCount = events.count
        
        // Quality Gate 1: Check minimum tap volume
        guard tapCount >= minimumTapsForValidSession else {
            return TappingMetrics(
                testedHand: testedHand,
                durationSeconds: actualDuration,
                tapCount: tapCount,
                cadenceHz: actualDuration > 0 ? Double(tapCount) / actualDuration : 0,
                meanIntervalMs: 0,
                medianIntervalMs: 0,
                intervalStdDevMs: 0,
                coefficientOfVariationPercent: 0,
                fatigueRatio: 1.0,
                qualityStatus: .tooFewTaps,
                qualityExplanation: "Fewer than \(minimumTapsForValidSession) taps were recorded. Please ensure active tapping during the full session window."
            )
        }
        
        // Quality Gate 2: Check test completion duration
        let completionRatio = actualDuration / max(plannedDuration, 1.0)
        let isPremature = completionRatio < 0.85
        
        // Compute Cadence (Hz = taps per second)
        let cadence = actualDuration > 0 ? Double(tapCount) / actualDuration : 0
        
        // Compute Inter-Tap Intervals (ITIs) in milliseconds
        var intervals: [Double] = []
        for i in 1..<events.count {
            let diffSec = events[i].elapsedSeconds - events[i - 1].elapsedSeconds
            if diffSec > 0 {
                intervals.append(diffSec * 1000.0)
            }
        }
        
        guard !intervals.isEmpty else {
            return TappingMetrics(
                testedHand: testedHand,
                durationSeconds: actualDuration,
                tapCount: tapCount,
                cadenceHz: cadence,
                meanIntervalMs: 0,
                medianIntervalMs: 0,
                intervalStdDevMs: 0,
                coefficientOfVariationPercent: 0,
                fatigueRatio: 1.0,
                qualityStatus: .interruptedEarly,
                qualityExplanation: "No valid inter-tap intervals could be measured."
            )
        }
        
        // Mean Interval
        let sum = intervals.reduce(0.0, +)
        let mean = sum / Double(intervals.count)
        
        // Median Interval
        let sorted = intervals.sorted()
        let median: Double
        let count = sorted.count
        if count % 2 == 0 {
            median = (sorted[count / 2 - 1] + sorted[count / 2]) / 2.0
        } else {
            median = sorted[count / 2]
        }
        
        // Sample Standard Deviation
        let variance: Double
        if count > 1 {
            let squaredDiffs = intervals.map { pow($0 - mean, 2) }
            variance = squaredDiffs.reduce(0.0, +) / Double(count - 1)
        } else {
            variance = 0.0
        }
        let stdDev = sqrt(variance)
        
        // Coefficient of Variation (CV %)
        let cv = mean > 0 ? (stdDev / mean) * 100.0 : 0.0
        
        // Fatigue ratio: compare 2nd half tap rate to 1st half tap rate
        let halfTime = actualDuration / 2.0
        let firstHalfTaps = events.filter { $0.elapsedSeconds < halfTime }.count
        let secondHalfTaps = events.filter { $0.elapsedSeconds >= halfTime }.count
        let fatigueRatio: Double
        if firstHalfTaps > 0 {
            fatigueRatio = Double(secondHalfTaps) / Double(firstHalfTaps)
        } else {
            fatigueRatio = 1.0
        }
        
        // Final Quality Determination
        let quality: AssessmentQualityStatus
        let explanation: String
        
        if isPremature {
            quality = .interruptedEarly
            explanation = "The test ended earlier than the planned \(Int(plannedDuration))s duration. Metrics reflect only the partial attempt."
        } else if cv > 85.0 {
            quality = .irregularTiming
            explanation = "High timing variability observed (CV > 85%). Try tapping in a continuous, steady rhythm."
        } else {
            quality = .valid
            explanation = "Session meets quality criteria with stable pacing and full duration."
        }
        
        return TappingMetrics(
            testedHand: testedHand,
            durationSeconds: actualDuration,
            tapCount: tapCount,
            cadenceHz: cadence,
            meanIntervalMs: mean,
            medianIntervalMs: median,
            intervalStdDevMs: stdDev,
            coefficientOfVariationPercent: cv,
            fatigueRatio: fatigueRatio,
            qualityStatus: quality,
            qualityExplanation: explanation
        )
    }
}
