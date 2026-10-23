//
//  TappingMetrics.swift
//  NeuroPulseAI
//
//  Transparent metrics calculated from a completed finger-tapping assessment,
//  including cadence, rhythm consistency, and two-zone center deviation statistics.
//

import Foundation

public enum AssessmentQualityStatus: String, Codable, Sendable {
    case valid = "Valid Session"
    case tooFewTaps = "Insufficient Taps"
    case insufficientPoints = "Insufficient Points"
    case interruptedEarly = "Interrupted"
    case irregularTiming = "Irregular Timing"
}

public struct TappingMetrics: Identifiable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let testedHand: String
    public let durationSeconds: TimeInterval
    public let tapCount: Int
    public let cadenceHz: Double
    public let meanIntervalMs: Double
    public let medianIntervalMs: Double
    public let intervalStdDevMs: Double
    public let coefficientOfVariationPercent: Double
    public let fatigueRatio: Double
    
    // Two-zone target accuracy & center deviation metrics
    public let meanCenterDeviationPoints: Double?
    public let meanNormalizedCenterDeviationPercent: Double?
    public let medianCenterDeviationPoints: Double?
    public let maxCenterDeviationPoints: Double?
    public let totalAttempts: Int
    public let correctAlternatingTaps: Int
    public let incorrectTargetAttempts: Int
    public let missedTargetAttempts: Int
    public let alternationAccuracyPercent: Double?
    
    public let qualityStatus: AssessmentQualityStatus
    public let qualityExplanation: String
    public let protocolVersion: String
    public let algorithmVersion: String
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        testedHand: String,
        durationSeconds: TimeInterval,
        tapCount: Int,
        cadenceHz: Double,
        meanIntervalMs: Double,
        medianIntervalMs: Double,
        intervalStdDevMs: Double,
        coefficientOfVariationPercent: Double,
        fatigueRatio: Double,
        meanCenterDeviationPoints: Double? = nil,
        meanNormalizedCenterDeviationPercent: Double? = nil,
        medianCenterDeviationPoints: Double? = nil,
        maxCenterDeviationPoints: Double? = nil,
        totalAttempts: Int? = nil,
        correctAlternatingTaps: Int? = nil,
        incorrectTargetAttempts: Int = 0,
        missedTargetAttempts: Int = 0,
        alternationAccuracyPercent: Double? = nil,
        qualityStatus: AssessmentQualityStatus,
        qualityExplanation: String,
        protocolVersion: String = "2.0",
        algorithmVersion: String = "2.0"
    ) {
        self.id = id
        self.timestamp = timestamp
        self.testedHand = testedHand
        self.durationSeconds = durationSeconds
        self.tapCount = tapCount
        self.cadenceHz = cadenceHz
        self.meanIntervalMs = meanIntervalMs
        self.medianIntervalMs = medianIntervalMs
        self.intervalStdDevMs = intervalStdDevMs
        self.coefficientOfVariationPercent = coefficientOfVariationPercent
        self.fatigueRatio = fatigueRatio
        
        self.meanCenterDeviationPoints = meanCenterDeviationPoints
        self.meanNormalizedCenterDeviationPercent = meanNormalizedCenterDeviationPercent
        self.medianCenterDeviationPoints = medianCenterDeviationPoints
        self.maxCenterDeviationPoints = maxCenterDeviationPoints
        self.totalAttempts = totalAttempts ?? tapCount
        self.correctAlternatingTaps = correctAlternatingTaps ?? tapCount
        self.incorrectTargetAttempts = incorrectTargetAttempts
        self.missedTargetAttempts = missedTargetAttempts
        self.alternationAccuracyPercent = alternationAccuracyPercent
        
        self.qualityStatus = qualityStatus
        self.qualityExplanation = qualityExplanation
        self.protocolVersion = protocolVersion
        self.algorithmVersion = algorithmVersion
    }
}
