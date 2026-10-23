//
//  MotorFeatureCalculatorTests.swift
//  NeuroPulseAITests
//
//  Deterministic unit tests verifying cadence, inter-tap intervals, median,
//  CV variability, fatigue ratio, two-zone alternating accuracy, and center deviation geometry.
//

import XCTest
import CoreGraphics
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
    
    func testTwoZoneCenterDeviationEuclideanDistance() {
        // Construct a single event with exact 3-4-5 right triangle offset:
        // Expected center (100, 100), Touch location (103, 104)
        // Euclidean distance = sqrt(3^2 + 4^2) = 5.0 pt
        // Radius = 25.0 pt -> Normalized = (5.0 / 25.0) * 100 = 20.0%
        let center = CGPoint(x: 100.0, y: 100.0)
        let touch = CGPoint(x: 103.0, y: 104.0)
        let radius: CGFloat = 25.0
        
        let event = TapEvent(
            elapsedSeconds: 1.0,
            target: .left,
            touchLocation: touch,
            expectedCenter: center,
            expectedRadius: radius,
            hitCategory: .correctTarget
        )
        
        XCTAssertNotNil(event.centerDeviationPoints)
        XCTAssertEqual(event.centerDeviationPoints!, 5.0, accuracy: 0.0001)
        
        XCTAssertNotNil(event.normalizedCenterDeviationPercent)
        XCTAssertEqual(event.normalizedCenterDeviationPercent!, 20.0, accuracy: 0.0001)
    }
    
    func testTwoZoneAlternatingAccuracyAndErrorHandling() {
        // Construct 10 attempts: 8 correct alternating hits, 1 wrong target hit, 1 outside both
        let leftCenter = CGPoint(x: 100, y: 200)
        let rightCenter = CGPoint(x: 300, y: 200)
        let radius: CGFloat = 32.0
        
        var events: [TapEvent] = []
        // 8 correct alternating taps (left, right, left, right, left, right, left, right)
        for i in 0..<8 {
            let target: TapTarget = (i % 2 == 0) ? .left : .right
            let center = (target == .left) ? leftCenter : rightCenter
            // Touched exactly at center (0 deviation)
            events.append(TapEvent(
                elapsedSeconds: Double(i) * 0.5,
                target: target,
                touchLocation: center,
                expectedCenter: center,
                expectedRadius: radius,
                hitCategory: .correctTarget
            ))
        }
        
        // 1 wrong-target attempt (expected left, touched right)
        events.append(TapEvent(
            elapsedSeconds: 4.5,
            target: .left,
            touchLocation: rightCenter,
            expectedCenter: leftCenter,
            expectedRadius: radius,
            hitCategory: .wrongTarget
        ))
        
        // 1 outside-both attempt (expected left, touched far away)
        events.append(TapEvent(
            elapsedSeconds: 5.0,
            target: .left,
            touchLocation: CGPoint(x: 10, y: 10),
            expectedCenter: leftCenter,
            expectedRadius: radius,
            hitCategory: .outsideBoth
        ))
        
        let metrics = MotorFeatureCalculator.calculateMetrics(
            events: events,
            plannedDuration: 15.0,
            actualDuration: 15.0,
            testedHand: "Right"
        )
        
        XCTAssertEqual(metrics.totalAttempts, 10)
        XCTAssertEqual(metrics.correctAlternatingTaps, 8)
        XCTAssertEqual(metrics.incorrectTargetAttempts, 1)
        XCTAssertEqual(metrics.missedTargetAttempts, 1)
        
        // Alternation accuracy = 8 / 10 * 100 = 80.0%
        XCTAssertNotNil(metrics.alternationAccuracyPercent)
        XCTAssertEqual(metrics.alternationAccuracyPercent!, 80.0, accuracy: 0.01)
        
        // Cadence should be calculated from the 8 accepted taps over 15s = 0.533 Hz
        XCTAssertEqual(metrics.cadenceHz, 8.0 / 15.0, accuracy: 0.01)
    }
    
    func testTwoZoneDeviationWithMultiplePoints() {
        // Construct 3 valid events with known offsets:
        // Event 1: offset 3 pt horizontally -> dev = 3.0 pt
        // Event 2: offset 4 pt vertically   -> dev = 4.0 pt
        // Event 3: offset 3 pt h, 4 pt v    -> dev = 5.0 pt
        // Mean dev = (3 + 4 + 5) / 3 = 4.0 pt
        // Median dev = 4.0 pt
        // Max dev = 5.0 pt
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 30.0
        
        var events: [TapEvent] = [
            TapEvent(
                elapsedSeconds: 0.5,
                target: .left,
                touchLocation: CGPoint(x: 103, y: 100),
                expectedCenter: center,
                expectedRadius: radius,
                hitCategory: .correctTarget
            ),
            TapEvent(
                elapsedSeconds: 1.0,
                target: .right,
                touchLocation: CGPoint(x: 100, y: 104),
                expectedCenter: center,
                expectedRadius: radius,
                hitCategory: .correctTarget
            ),
            TapEvent(
                elapsedSeconds: 1.5,
                target: .left,
                touchLocation: CGPoint(x: 103, y: 104),
                expectedCenter: center,
                expectedRadius: radius,
                hitCategory: .correctTarget
            ),
            TapEvent(
                elapsedSeconds: 2.0,
                target: .right,
                touchLocation: CGPoint(x: 100, y: 100),
                expectedCenter: center,
                expectedRadius: radius,
                hitCategory: .correctTarget
            ),
            TapEvent(
                elapsedSeconds: 2.5,
                target: .left,
                touchLocation: CGPoint(x: 100, y: 100),
                expectedCenter: center,
                expectedRadius: radius,
                hitCategory: .correctTarget
            ),
            TapEvent(
                elapsedSeconds: 3.0,
                target: .right,
                touchLocation: CGPoint(x: 100, y: 100),
                expectedCenter: center,
                expectedRadius: radius,
                hitCategory: .correctTarget
            )
        ]
        
        let metrics = MotorFeatureCalculator.calculateMetrics(
            events: events,
            plannedDuration: 15.0,
            actualDuration: 15.0,
            testedHand: "Left"
        )
        
        XCTAssertNotNil(metrics.meanCenterDeviationPoints)
        XCTAssertNotNil(metrics.maxCenterDeviationPoints)
        XCTAssertEqual(metrics.maxCenterDeviationPoints!, 5.0, accuracy: 0.001)
        XCTAssertGreaterThan(metrics.meanCenterDeviationPoints!, 0.0)
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
        XCTAssertNil(emptyMetrics.meanCenterDeviationPoints)
        XCTAssertNil(emptyMetrics.alternationAccuracyPercent)
    }
}
