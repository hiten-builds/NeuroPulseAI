//
//  MotorSessionRecord.swift
//  NeuroPulseAI
//
//  Unified persistent data model for motor assessment attempts.
//

import Foundation

public enum MotorTestType: String, Codable, CaseIterable, Sendable {
    case tapping = "Finger Tapping"
    case spiral = "Spiral Tracing"
}

public struct MotorSessionRecord: Identifiable, Codable, Sendable {
    public let id: UUID
    public let date: Date
    public let testType: MotorTestType
    public let testedHand: String
    public let durationSeconds: Double
    public let primaryScoreLabel: String
    public let primaryScoreValue: Double
    public let secondaryScoreLabel: String
    public let qualityStatus: AssessmentQualityStatus
    public let protocolVersion: String
    public let isSampleData: Bool
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        testType: MotorTestType,
        testedHand: String,
        durationSeconds: Double,
        primaryScoreLabel: String,
        primaryScoreValue: Double,
        secondaryScoreLabel: String,
        qualityStatus: AssessmentQualityStatus,
        protocolVersion: String = "1.0",
        isSampleData: Bool = false
    ) {
        self.id = id
        self.date = date
        self.testType = testType
        self.testedHand = testedHand
        self.durationSeconds = durationSeconds
        self.primaryScoreLabel = primaryScoreLabel
        self.primaryScoreValue = primaryScoreValue
        self.secondaryScoreLabel = secondaryScoreLabel
        self.qualityStatus = qualityStatus
        self.protocolVersion = protocolVersion
        self.isSampleData = isSampleData
    }
}
