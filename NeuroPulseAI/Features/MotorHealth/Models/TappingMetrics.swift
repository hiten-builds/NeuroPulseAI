//
//  TappingMetrics.swift
//  NeuroPulseAI
//
//  Transparent metrics calculated from a completed finger-tapping assessment.
//

import Foundation

public enum AssessmentQualityStatus: String, Codable, Sendable {
    case valid = "Valid Session"
    case tooFewTaps = "Insufficient Taps"
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
        qualityStatus: AssessmentQualityStatus,
        qualityExplanation: String,
        protocolVersion: String = "1.0",
        algorithmVersion: String = "1.0"
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
        self.qualityStatus = qualityStatus
        self.qualityExplanation = qualityExplanation
        self.protocolVersion = protocolVersion
        self.algorithmVersion = algorithmVersion
    }
}
