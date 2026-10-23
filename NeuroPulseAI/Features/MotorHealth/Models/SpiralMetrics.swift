//
//  SpiralMetrics.swift
//  NeuroPulseAI
//
//  Geometric and kinematic metrics derived from spiral tracing.
//

import Foundation

public struct SpiralMetrics: Identifiable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let testedHand: String
    public let durationSeconds: TimeInterval
    public let pointCount: Int
    /// Root-mean-square deviation error from reference spiral in percentage points
    public let rmsePercent: Double
    /// Mean radial distance error from reference spiral in percentage points
    public let meanDeviationPercent: Double
    /// Ratio of user drawn path length to ideal reference spiral arc length
    public let pathLengthRatio: Double
    /// Drawing speed variability (coefficient of variation %)
    public let speedVariabilityPercent: Double
    /// Quality determination
    public let qualityStatus: AssessmentQualityStatus
    public let qualityExplanation: String
    public let protocolVersion: String
    public let algorithmVersion: String
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        testedHand: String,
        durationSeconds: TimeInterval,
        pointCount: Int,
        rmsePercent: Double,
        meanDeviationPercent: Double,
        pathLengthRatio: Double,
        speedVariabilityPercent: Double,
        qualityStatus: AssessmentQualityStatus,
        qualityExplanation: String,
        protocolVersion: String = "1.0",
        algorithmVersion: String = "1.0"
    ) {
        self.id = id
        self.timestamp = timestamp
        self.testedHand = testedHand
        self.durationSeconds = durationSeconds
        self.pointCount = pointCount
        self.rmsePercent = rmsePercent
        self.meanDeviationPercent = meanDeviationPercent
        self.pathLengthRatio = pathLengthRatio
        self.speedVariabilityPercent = speedVariabilityPercent
        self.qualityStatus = qualityStatus
        self.qualityExplanation = qualityExplanation
        self.protocolVersion = protocolVersion
        self.algorithmVersion = algorithmVersion
    }
}
