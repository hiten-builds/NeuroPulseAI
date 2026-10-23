//
//  MonotonicClockTests.swift
//  NeuroPulseAITests
//
//  Unit tests verifying monotonic timing guarantees and elapsed calculation.
//

import XCTest
@testable import NeuroPulseAI

final class MonotonicClockTests: XCTestCase {
    
    func testMonotonicTimestampNonDecreasing() {
        let t1 = MonotonicClock.nowNanoseconds()
        let t2 = MonotonicClock.nowNanoseconds()
        let t3 = MonotonicClock.nowNanoseconds()
        
        XCTAssertGreaterThanOrEqual(t2, t1)
        XCTAssertGreaterThanOrEqual(t3, t2)
    }
    
    func testElapsedSecondsCalculation() {
        let startNanos = MonotonicClock.nowNanoseconds()
        // Sleep 15 milliseconds
        usleep(15_000)
        let elapsed = MonotonicClock.elapsedSeconds(since: startNanos)
        
        XCTAssertGreaterThanOrEqual(elapsed, 0.010)
        XCTAssertLessThan(elapsed, 1.0)
    }
    
    func testElapsedSecondsNegativeDeltaProtection() {
        // In case start is in the future compared to reference, elapsedSeconds must return 0.0, never negative
        let futureNanos = UInt64.max
        let elapsed = MonotonicClock.elapsedSeconds(since: futureNanos)
        XCTAssertEqual(elapsed, 0.0)
    }
}
