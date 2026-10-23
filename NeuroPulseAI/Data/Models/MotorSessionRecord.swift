//
//  MotorSessionRecord.swift
//  NeuroPulseAI
//
//  Unified persistent data model for motor assessment attempts,
//  supporting tapping center deviation, spiral metrics, and backward compatibility.
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
    
    // Feature B enhancements (optional for backward compatibility)
    public let completionStatus: String
    public let meanCenterDeviationPoints: Double?
    public let meanNormalizedCenterDeviationPercent: Double?
    public let totalAttempts: Int?
    public let correctAlternatingTaps: Int?
    public let alternationAccuracyPercent: Double?
    
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
        protocolVersion: String = "2.0",
        isSampleData: Bool = false,
        completionStatus: String = "Completed",
        meanCenterDeviationPoints: Double? = nil,
        meanNormalizedCenterDeviationPercent: Double? = nil,
        totalAttempts: Int? = nil,
        correctAlternatingTaps: Int? = nil,
        alternationAccuracyPercent: Double? = nil
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
        self.completionStatus = completionStatus
        self.meanCenterDeviationPoints = meanCenterDeviationPoints
        self.meanNormalizedCenterDeviationPercent = meanNormalizedCenterDeviationPercent
        self.totalAttempts = totalAttempts
        self.correctAlternatingTaps = correctAlternatingTaps
        self.alternationAccuracyPercent = alternationAccuracyPercent
    }
    
    // Custom Decodable to guarantee older saved JSON without the new fields decodes flawlessly
    enum CodingKeys: String, CodingKey {
        case id, date, testType, testedHand, durationSeconds
        case primaryScoreLabel, primaryScoreValue, secondaryScoreLabel
        case qualityStatus, protocolVersion, isSampleData
        case completionStatus, meanCenterDeviationPoints, meanNormalizedCenterDeviationPercent
        case totalAttempts, correctAlternatingTaps, alternationAccuracyPercent
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.date = try container.decode(Date.self, forKey: .date)
        self.testType = try container.decode(MotorTestType.self, forKey: .testType)
        self.testedHand = try container.decode(String.self, forKey: .testedHand)
        self.durationSeconds = try container.decode(Double.self, forKey: .durationSeconds)
        self.primaryScoreLabel = try container.decode(String.self, forKey: .primaryScoreLabel)
        self.primaryScoreValue = try container.decode(Double.self, forKey: .primaryScoreValue)
        self.secondaryScoreLabel = try container.decode(String.self, forKey: .secondaryScoreLabel)
        self.qualityStatus = try container.decode(AssessmentQualityStatus.self, forKey: .qualityStatus)
        self.protocolVersion = try container.decodeIfPresent(String.self, forKey: .protocolVersion) ?? "1.0"
        self.isSampleData = try container.decodeIfPresent(Bool.self, forKey: .isSampleData) ?? false
        self.completionStatus = try container.decodeIfPresent(String.self, forKey: .completionStatus) ?? "Completed"
        self.meanCenterDeviationPoints = try container.decodeIfPresent(Double.self, forKey: .meanCenterDeviationPoints)
        self.meanNormalizedCenterDeviationPercent = try container.decodeIfPresent(Double.self, forKey: .meanNormalizedCenterDeviationPercent)
        self.totalAttempts = try container.decodeIfPresent(Int.self, forKey: .totalAttempts)
        self.correctAlternatingTaps = try container.decodeIfPresent(Int.self, forKey: .correctAlternatingTaps)
        self.alternationAccuracyPercent = try container.decodeIfPresent(Double.self, forKey: .alternationAccuracyPercent)
    }
}
