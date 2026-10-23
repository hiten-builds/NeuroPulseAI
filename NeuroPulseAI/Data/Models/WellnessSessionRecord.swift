//
//  WellnessSessionRecord.swift
//  NeuroPulseAI
//
//  Data model for mindful wellness activities, stored strictly separate from motor assessments.
//

import Foundation

public enum WellnessActivityType: String, Codable, CaseIterable, Sendable {
    case breathing = "Guided Breathing"
    case meditation = "Mindfulness Pause"
    case mindfulTracing = "Mindful Tracing"
}

public struct WellnessSessionRecord: Identifiable, Codable, Sendable {
    public let id: UUID
    public let accountID: String?
    public let date: Date
    public let activityType: WellnessActivityType
    public let durationSeconds: Double
    public let completionStatus: String
    public let ratingBefore: Int?
    public let ratingAfter: Int?
    
    public init(
        id: UUID = UUID(),
        accountID: String? = nil,
        date: Date = Date(),
        activityType: WellnessActivityType,
        durationSeconds: Double,
        completionStatus: String = "Completed",
        ratingBefore: Int? = nil,
        ratingAfter: Int? = nil
    ) {
        self.id = id
        self.accountID = accountID
        self.date = date
        self.activityType = activityType
        self.durationSeconds = durationSeconds
        self.completionStatus = completionStatus
        self.ratingBefore = ratingBefore
        self.ratingAfter = ratingAfter
    }
    
    enum CodingKeys: String, CodingKey {
        case id, accountID, date, activityType, durationSeconds, completionStatus, ratingBefore, ratingAfter
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.accountID = try container.decodeIfPresent(String.self, forKey: .accountID)
        self.date = try container.decode(Date.self, forKey: .date)
        self.activityType = try container.decode(WellnessActivityType.self, forKey: .activityType)
        self.durationSeconds = try container.decode(Double.self, forKey: .durationSeconds)
        self.completionStatus = try container.decodeIfPresent(String.self, forKey: .completionStatus) ?? "Completed"
        self.ratingBefore = try container.decodeIfPresent(Int.self, forKey: .ratingBefore)
        self.ratingAfter = try container.decodeIfPresent(Int.self, forKey: .ratingAfter)
    }
}
