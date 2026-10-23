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
    public let date: Date
    public let activityType: WellnessActivityType
    public let durationSeconds: Double
    public let completionStatus: String
    public let ratingBefore: Int?
    public let ratingAfter: Int?
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        activityType: WellnessActivityType,
        durationSeconds: Double,
        completionStatus: String = "Completed",
        ratingBefore: Int? = nil,
        ratingAfter: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.activityType = activityType
        self.durationSeconds = durationSeconds
        self.completionStatus = completionStatus
        self.ratingBefore = ratingBefore
        self.ratingAfter = ratingAfter
    }
}
