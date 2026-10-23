//
//  TapEvent.swift
//  NeuroPulseAI
//
//  Represents a single timestamped tap event captured during a motor assessment.
//

import Foundation

public enum TapTarget: String, Codable, Sendable {
    case primary
    case left
    case right
}

public struct TapEvent: Identifiable, Codable, Sendable {
    public let id: UUID
    /// Monotonic elapsed time in seconds from test start
    public let elapsedSeconds: TimeInterval
    public let target: TapTarget
    
    public init(id: UUID = UUID(), elapsedSeconds: TimeInterval, target: TapTarget = .primary) {
        self.id = id
        self.elapsedSeconds = elapsedSeconds
        self.target = target
    }
}
