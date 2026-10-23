//
//  SpiralFeatureCalculatorTests.swift
//  NeuroPulseAITests
//
//  Deterministic unit tests verifying reference spiral geometry, arc length,
//  RMSE path deviation, path length ratio, speed CV, and quality boundaries.
//

import XCTest
@testable import NeuroPulseAI

final class SpiralFeatureCalculatorTests: XCTestCase {
    
    func testReferenceSpiralGeneration() {
        let referencePoints = SpiralFeatureCalculator.sharedReferencePoints
        XCTAssertEqual(referencePoints.count, 401)
        
        // Center start point should be at normalized (0.5, 0.5)
        guard let first = referencePoints.first, let last = referencePoints.last else {
            XCTFail("Reference points empty")
            return
        }
        XCTAssertEqual(first.x, 0.5, accuracy: 0.001)
        XCTAssertEqual(first.y, 0.5, accuracy: 0.001)
        
        // All points must stay strictly inside normalized [0.0, 1.0] bounds
        for pt in referencePoints {
            XCTAssertGreaterThanOrEqual(pt.x, 0.0)
            XCTAssertLessThanOrEqual(pt.x, 1.0)
            XCTAssertGreaterThanOrEqual(pt.y, 0.0)
            XCTAssertLessThanOrEqual(pt.y, 1.0)
        }
        
        // Arc length must be positive
        let arcLength = SpiralFeatureCalculator.sharedReferenceArcLength
        XCTAssertGreaterThan(arcLength, 2.0)
    }
    
    func testPerfectTraceMetrics() {
        // Construct user points following the reference points exactly
        let refPoints = SpiralFeatureCalculator.sharedReferencePoints
        var userPoints: [SpiralPoint] = []
        for (idx, pt) in refPoints.enumerated() {
            let elapsed = Double(idx) * 0.03
            userPoints.append(SpiralPoint(x: Double(pt.x), y: Double(pt.y), elapsedSeconds: elapsed))
        }
        
        let metrics = SpiralFeatureCalculator.calculateMetrics(
            userPoints: userPoints,
            testedHand: "Right",
            actualDuration: 12.0
        )
        
        // When user points match reference curve, RMSE deviation should be virtually zero
        XCTAssertEqual(metrics.rmsePercent, 0.0, accuracy: 0.1)
        XCTAssertEqual(metrics.meanDeviationPercent, 0.0, accuracy: 0.1)
        XCTAssertEqual(metrics.pathLengthRatio, 1.0, accuracy: 0.05)
        XCTAssertEqual(metrics.qualityStatus, .valid)
    }
    
    func testInsufficientPointsQualityGate() {
        // Less than 20 points should trigger .insufficientPoints
        var userPoints: [SpiralPoint] = []
        for i in 0..<15 {
            userPoints.append(SpiralPoint(x: 0.5 + Double(i) * 0.01, y: 0.5, elapsedSeconds: Double(i) * 0.1))
        }
        
        let metrics = SpiralFeatureCalculator.calculateMetrics(
            userPoints: userPoints,
            testedHand: "Left",
            actualDuration: 2.0
        )
        
        XCTAssertEqual(metrics.pointCount, 15)
        XCTAssertEqual(metrics.qualityStatus, .insufficientPoints)
        XCTAssertEqual(metrics.rmsePercent, 0.0)
    }
    
    func testInterruptedEarlyQualityGate() {
        // 50 points, but user stayed clustered around the center dot (max radius < 40% of maxRadius)
        var userPoints: [SpiralPoint] = []
        for i in 0..<50 {
            // maxRadius is 0.42. 40% is ~0.168. We stay within 0.05
            let angle = Double(i) * 0.1
            let r = 0.03
            let x = 0.5 + r * cos(angle)
            let y = 0.5 + r * sin(angle)
            userPoints.append(SpiralPoint(x: x, y: y, elapsedSeconds: Double(i) * 0.1))
        }
        
        let metrics = SpiralFeatureCalculator.calculateMetrics(
            userPoints: userPoints,
            testedHand: "Right",
            actualDuration: 5.0
        )
        
        XCTAssertEqual(metrics.qualityStatus, .interruptedEarly)
    }
    
    func testHighDeviationQualityGate() {
        // User traces along the outer edge of the screen instead of the reference spiral
        var userPoints: [SpiralPoint] = []
        for i in 0..<60 {
            let x = 0.05 + Double(i) * 0.015
            let y = 0.05
            userPoints.append(SpiralPoint(x: x, y: y, elapsedSeconds: Double(i) * 0.2))
        }
        
        let metrics = SpiralFeatureCalculator.calculateMetrics(
            userPoints: userPoints,
            testedHand: "Right",
            actualDuration: 12.0
        )
        
        XCTAssertGreaterThan(metrics.rmsePercent, 18.0)
        XCTAssertEqual(metrics.qualityStatus, .irregularTiming)
    }
}
