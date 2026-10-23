//
//  MotorFeatureCalculatorTests.swift
//  NeuroPulseAITests
//
//  Deterministic unit tests verifying cadence, inter-tap intervals, median,
//  CV variability, fatigue ratio, and quality boundaries.
//

import XCTest
@testable import NeuroPulseAI

final class MotorFeatureCalculatorTests: XCTestCase {
    
    func testRegularTappingCadenceAndIntervals() {
        // Construct 16 taps at exact 200ms (0.2s) intervals across 3.0 seconds
        var events: [TapEvent] = []
        for i in 0..<16 {
            let elapsed = Double(i) * 0.20
            events.append(TapEvent(elapsedSeconds: elapsed, target: .primary))
        }
        
        let metrics = MotorFeatureCalculator.calculateMetrics(
            events: events,
            plannedDuration: 15.0,
            actualDuration: 15.0,
            testedHand: "Right"
        )
        
        // 16 taps over 15.0s = 1.0667 Hz
        XCTAssertEqual(metrics.tapCount, 16)
        XCTAssertEqual(metrics.testedHand, "Right")
        XCTAssertEqual(metrics.cadenceHz, 16.0 / 15.0, accuracy: 0.001)
        XCTAssertEqual(metrics.meanIntervalMs, 200.0, accuracy: 0.01)
        XCTAssertEqual(metrics.medianIntervalMs, 200.0, accuracy: 0.01)
        XCTAssertEqual(metrics.intervalStdDevMs, 0.0, accuracy: 0.01)
        XCTAssertEqual(metrics.coefficientOfVariationPercent, 0.0, accuracy: 0.01)
        XCTAssertEqual(metrics.qualityStatus, .valid)
    }
    
    func testInsufficientTapsQualityGate() {
        // Less than 5 taps should trigger .tooFewTaps
        let events = [
            TapEvent(elapsedSeconds: 1.0, target: .primary),
            TapEvent(elapsedSeconds: 2.0, target: .primary),
            TapEvent(elapsedSeconds: 3.0, target: .primary)
        ]
        
        let metrics = MotorFeatureCalculator.calculateMetrics(
            events: events,
            plannedDuration: 15.0,
            actualDuration: 15.0,
            testedHand: "Left"
        )
        
        XCTAssertEqual(metrics.tapCount, 3)
        XCTAssertEqual(metrics.qualityStatus, .tooFewTaps)
        XCTAssertEqual(metrics.meanIntervalMs, 0.0)
        XCTAssertEqual(metrics.medianIntervalMs, 0.0)
    }
    
    func testPrematureInterruptedSessionQualityGate() {
        // 10 taps but actual duration is only 5.0s on a 15.0s planned protocol (ratio = 0.33 < 0.85)
        var events: [TapEvent] = []
        for i in 0..<10 {
            events.append(TapEvent(elapsedSeconds: Double(i) * 0.4, target: .primary))
        }
        
        let metrics = MotorFeatureCalculator.calculateMetrics(
            events: events,
            plannedDuration: 15.0,
            actualDuration: 5.0,
            testedHand: "Right"
        )
        
        XCTAssertEqual(metrics.qualityStatus, .interruptedEarly)
    }
    
    func testIrregularTimingQualityGate() {
        // Taps with erratic intervals resulting in CV > 85%
        let events = [
            TapEvent(elapsedSeconds: 0.1, target: .primary),
            TapEvent(elapsedSeconds: 0.15, target: .primary),
            TapEvent(elapsedSeconds: 0.2, target: .primary),
            TapEvent(elapsedSeconds: 5.0, target: .primary),
            TapEvent(elapsedSeconds: 5.05, target: .primary),
            TapEvent(elapsedSeconds: 14.5, target: .primary)
        ]
        
        let metrics = MotorFeatureCalculator.calculateMetrics(
            events: events,
            plannedDuration: 15.0,
            actualDuration: 15.0,
            testedHand: "Right"
        )
        
        XCTAssertGreaterThan(metrics.coefficientOfVariationPercent, 85.0)
        XCTAssertEqual(metrics.qualityStatus, .irregularTiming)
    }
    
    func testFatigueRatioCalculation() {
        // First half (0..7.5s): 10 taps. Second half (7.5..15.0s): 5 taps. Fatigue ratio = 5 / 10 = 0.50
        var events: [TapEvent] = []
        for i in 0..<10 {
            events.append(TapEvent(elapsedSeconds: 1.0 + Double(i) * 0.5, target: .primary))
        }
        for i in 0..<5 {
            events.append(TapEvent(elapsedSeconds: 8.0 + Double(i) * 1.0, target: .primary))
        }
        
        let metrics = MotorFeatureCalculator.calculateMetrics(
            events: events,
            plannedDuration: 15.0,
            actualDuration: 15.0,
            testedHand: "Right"
        )
        
        XCTAssertEqual(metrics.fatigueRatio, 5.0 / 10.0, accuracy: 0.01)
    }
    
    func testZeroAndBoundaryCases() {
        // Empty events array
        let emptyMetrics = MotorFeatureCalculator.calculateMetrics(
            events: [],
            plannedDuration: 15.0,
            actualDuration: 0.0,
            testedHand: "Right"
        )
        XCTAssertEqual(emptyMetrics.tapCount, 0)
        XCTAssertEqual(emptyMetrics.cadenceHz, 0.0)
        XCTAssertEqual(emptyMetrics.qualityStatus, .tooFewTaps)
    }
}
