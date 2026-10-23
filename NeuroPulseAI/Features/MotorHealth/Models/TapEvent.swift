//
//  TapEvent.swift
//  NeuroPulseAI
//
//  Represents a single timestamped tap event captured during a motor assessment,
//  including precise contact coordinates and target center deviation geometry.
//

import Foundation
import CoreGraphics

public enum TapTarget: String, Codable, Sendable {
    case primary
    case left
    case right
}

public enum TapHitCategory: String, Codable, Sendable {
    case correctTarget
    case wrongTarget
    case outsideBoth
}

public struct TapEvent: Identifiable, Codable, Sendable {
    public let id: UUID
    /// Monotonic elapsed time in seconds from test start
    public let elapsedSeconds: TimeInterval
    public let target: TapTarget
    
    // Geometric accuracy properties for two-zone protocol
    public let touchLocationX: Double?
    public let touchLocationY: Double?
    public let expectedCenterX: Double?
    public let expectedCenterY: Double?
    public let expectedRadius: Double?
    public let hitCategory: TapHitCategory?
    
    public init(
        id: UUID = UUID(),
        elapsedSeconds: TimeInterval,
        target: TapTarget = .primary,
        touchLocation: CGPoint? = nil,
        expectedCenter: CGPoint? = nil,
        expectedRadius: CGFloat? = nil,
        hitCategory: TapHitCategory? = nil
    ) {
        self.id = id
        self.elapsedSeconds = elapsedSeconds
        self.target = target
        
        if let loc = touchLocation {
            self.touchLocationX = Double(loc.x)
            self.touchLocationY = Double(loc.y)
        } else {
            self.touchLocationX = nil
            self.touchLocationY = nil
        }
        
        if let center = expectedCenter {
            self.expectedCenterX = Double(center.x)
            self.expectedCenterY = Double(center.y)
        } else {
            self.expectedCenterX = nil
            self.expectedCenterY = nil
        }
        
        if let radius = expectedRadius {
            self.expectedRadius = Double(radius)
        } else {
            self.expectedRadius = nil
        }
        
        self.hitCategory = hitCategory
    }
    
    /// Euclidean distance from actual touch location to the center of the expected target in points.
    public var centerDeviationPoints: Double? {
        guard let tx = touchLocationX, let ty = touchLocationY,
              let cx = expectedCenterX, let cy = expectedCenterY,
              tx.isFinite, ty.isFinite, cx.isFinite, cy.isFinite else {
            return nil
        }
        let dx = tx - cx
        let dy = ty - cy
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Center deviation normalized as a percentage of the expected target radius.
    public var normalizedCenterDeviationPercent: Double? {
        guard let deviation = centerDeviationPoints,
              let radius = expectedRadius,
              radius > 0 else {
            return nil
        }
        return (deviation / radius) * 100.0
    }
}
