//
//  MonotonicClock.swift
//  NeuroPulseAI
//
//  High-resolution monotonic clock utility for fine-motor assessment timing.
//  Uses DispatchTime uptime nanoseconds to guarantee non-decreasing elapsed time
//  independent of wall-clock changes, timezones, or leap seconds.
//

import Foundation

public enum MonotonicClock {
    /// Captures the current monotonic timestamp in nanoseconds.
    @inlinable
    public static func nowNanoseconds() -> UInt64 {
        DispatchTime.now().uptimeNanoseconds
    }
    
    /// Computes elapsed time in seconds since a starting monotonic nanosecond timestamp.
    /// Guarantees a nonnegative result without division by variable denominators.
    @inlinable
    public static func elapsedSeconds(since startNanos: UInt64) -> TimeInterval {
        let now = DispatchTime.now().uptimeNanoseconds
        guard now >= startNanos else { return 0.0 }
        let deltaNanos = now - startNanos
        return Double(deltaNanos) / 1_000_000_000.0
    }
    
    /// Computes elapsed time in seconds between two monotonic nanosecond timestamps.
    @inlinable
    public static func elapsedSeconds(from startNanos: UInt64, to endNanos: UInt64) -> TimeInterval {
        guard endNanos >= startNanos else { return 0.0 }
        let deltaNanos = endNanos - startNanos
        return Double(deltaNanos) / 1_000_000_000.0
    }
}
