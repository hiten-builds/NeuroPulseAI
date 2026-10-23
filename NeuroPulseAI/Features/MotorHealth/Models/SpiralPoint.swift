//
//  SpiralPoint.swift
//  NeuroPulseAI
//
//  Represents a normalized coordinate point captured during spiral tracing.
//

import Foundation
import CoreGraphics

public struct SpiralPoint: Identifiable, Codable, Sendable {
    public let id: UUID
    /// Normalized coordinates in [0, 1] range relative to canvas dimensions
    public let x: Double
    public let y: Double
    /// Monotonic elapsed time in seconds from drawing start
    public let elapsedSeconds: TimeInterval
    
    public init(id: UUID = UUID(), x: Double, y: Double, elapsedSeconds: TimeInterval) {
        self.id = id
        self.x = x
        self.y = y
        self.elapsedSeconds = elapsedSeconds
    }
    
    public var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}
