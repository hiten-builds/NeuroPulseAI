//
//  SpiralFeatureCalculator.swift
//  NeuroPulseAI
//
//  Mathematical Archimedean reference spiral generator and geometric deviation calculator.
//

import Foundation
import CoreGraphics

public struct SpiralFeatureCalculator {
    public static let maxTheta: Double = 3.5 * 2.0 * .pi // 3.5 revolutions
    public static let maxRadius: Double = 0.42           // Normalized radius in [0, 1] bounds
    public static let referenceSamplePoints: Int = 400
    public static let minimumPointsForValidSession: Int = 20
    
    /// Generates normalized reference points for drawing and metric projection.
    public static func generateReferencePoints() -> [CGPoint] {
        let a = maxRadius / maxTheta
        var points: [CGPoint] = []
        points.reserveCapacity(referenceSamplePoints)
        
        for i in 0...referenceSamplePoints {
            let theta = (Double(i) / Double(referenceSamplePoints)) * maxTheta
            let r = a * theta
            let x = 0.5 + r * cos(theta)
            let y = 0.5 + r * sin(theta)
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
    
    /// Computes total reference path length.
    public static func calculateReferenceArcLength(referencePoints: [CGPoint]) -> Double {
        var length: Double = 0.0
        for i in 1..<referencePoints.count {
            let dx = referencePoints[i].x - referencePoints[i - 1].x
            let dy = referencePoints[i].y - referencePoints[i - 1].y
            length += sqrt(dx * dx + dy * dy)
        }
        return length
    }
    
    /// Computes trace metrics comparing captured user points to the reference spiral.
    public static func calculateMetrics(
        userPoints: [SpiralPoint],
        testedHand: String,
        actualDuration: TimeInterval
    ) -> SpiralMetrics {
        let pointCount = userPoints.count
        let referencePoints = generateReferencePoints()
        let refArcLength = calculateReferenceArcLength(referencePoints: referencePoints)
        
        // Quality Gate 1: Minimum point volume
        guard pointCount >= minimumPointsForValidSession else {
            return SpiralMetrics(
                testedHand: testedHand,
                durationSeconds: actualDuration,
                pointCount: pointCount,
                rmsePercent: 0,
                meanDeviationPercent: 0,
                pathLengthRatio: 0,
                speedVariabilityPercent: 0,
                qualityStatus: .tooFewTaps,
                qualityExplanation: "Fewer than \(minimumPointsForValidSession) points recorded. Please trace smoothly from the center outwards."
            )
        }
        
        // 1. Calculate Minimum Distance from each User Point to the Reference Curve
        var squaredDistances: [Double] = []
        var distances: [Double] = []
        squaredDistances.reserveCapacity(pointCount)
        distances.reserveCapacity(pointCount)
        
        var maxUserRadius: Double = 0.0
        
        for p in userPoints {
            let dxCenter = p.x - 0.5
            let dyCenter = p.y - 0.5
            let r = sqrt(dxCenter * dxCenter + dyCenter * dyCenter)
            if r > maxUserRadius {
                maxUserRadius = r
            }
            
            // Find closest distance to reference curve
            var minDistance = Double.infinity
            for ref in referencePoints {
                let dx = p.x - Double(ref.x)
                let dy = p.y - Double(ref.y)
                let d = sqrt(dx * dx + dy * dy)
                if d < minDistance {
                    minDistance = d
                }
            }
            distances.append(minDistance)
            squaredDistances.append(minDistance * minDistance)
        }
        
        // 2. RMSE and Mean Deviation (scaled to percentage of canvas dimension)
        let meanSquare = squaredDistances.reduce(0.0, +) / Double(pointCount)
        let rmsePercent = sqrt(meanSquare) * 100.0
        let meanDeviationPercent = (distances.reduce(0.0, +) / Double(pointCount)) * 100.0
        
        // 3. User Drawn Path Length & Ratio
        var userPathLength: Double = 0.0
        var speeds: [Double] = []
        
        for i in 1..<userPoints.count {
            let dx = userPoints[i].x - userPoints[i - 1].x
            let dy = userPoints[i].y - userPoints[i - 1].y
            let segLen = sqrt(dx * dx + dy * dy)
            userPathLength += segLen
            
            let dt = userPoints[i].elapsedSeconds - userPoints[i - 1].elapsedSeconds
            if dt > 0.001 {
                speeds.append(segLen / dt)
            }
        }
        
        let pathLengthRatio = refArcLength > 0 ? userPathLength / refArcLength : 1.0
        
        // 4. Speed Variability (CV %)
        let speedCV: Double
        if speeds.count > 1 {
            let speedMean = speeds.reduce(0.0, +) / Double(speeds.count)
            if speedMean > 0 {
                let speedVariance = speeds.map { pow($0 - speedMean, 2) }.reduce(0.0, +) / Double(speeds.count - 1)
                speedCV = (sqrt(speedVariance) / speedMean) * 100.0
            } else {
                speedCV = 0.0
            }
        } else {
            speedCV = 0.0
        }
        
        // 5. Quality Determination
        let quality: AssessmentQualityStatus
        let explanation: String
        
        if maxUserRadius < (maxRadius * 0.40) {
            quality = .interruptedEarly
            explanation = "Tracing ended early before reaching outer loops. Try tracing from the center through the full pattern."
        } else if rmsePercent > 18.0 {
            quality = .irregularTiming
            explanation = "Higher path deviation detected (RMSE > 18%). Take your time to align with the guide line."
        } else {
            quality = .valid
            explanation = "Session meets quality criteria with complete trajectory and good path alignment."
        }
        
        return SpiralMetrics(
            testedHand: testedHand,
            durationSeconds: actualDuration,
            pointCount: pointCount,
            rmsePercent: rmsePercent,
            meanDeviationPercent: meanDeviationPercent,
            pathLengthRatio: pathLengthRatio,
            speedVariabilityPercent: speedCV,
            qualityStatus: quality,
            qualityExplanation: explanation
        )
    }
}
