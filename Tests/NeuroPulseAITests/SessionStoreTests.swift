//
//  SessionStoreTests.swift
//  NeuroPulseAITests
//
//  Unit tests verifying isolated persistence of motor and wellness sessions.
//

import XCTest
@testable import NeuroPulseAI

@MainActor
final class SessionStoreTests: XCTestCase {
    var temporaryDirectory: URL!
    
    override func setUp() {
        super.setUp()
        temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("NeuroPulseAITests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: temporaryDirectory)
        super.tearDown()
    }
    
    func testMotorSessionStoreSaveAndReload() {
        let store = MotorSessionStore(customDirectory: temporaryDirectory)
        XCTAssertEqual(store.records.count, 0)
        
        let record = MotorSessionRecord(
            testType: .tapping,
            testedHand: "Right",
            durationSeconds: 15.0,
            primaryScoreLabel: "5.5 Hz",
            primaryScoreValue: 5.5,
            secondaryScoreLabel: "82 taps",
            qualityStatus: .valid,
            protocolVersion: "1.0",
            isSampleData: false
        )
        
        store.save(record: record)
        XCTAssertEqual(store.records.count, 1)
        XCTAssertEqual(store.records.first?.id, record.id)
        
        // Instantiate a second store pointing to the exact same temporary directory
        let store2 = MotorSessionStore(customDirectory: temporaryDirectory)
        XCTAssertEqual(store2.records.count, 1)
        XCTAssertEqual(store2.records.first?.primaryScoreLabel, "5.5 Hz")
        XCTAssertEqual(store2.records.first?.testedHand, "Right")
    }
    
    func testWellnessSessionStoreSaveAndReload() {
        let store = WellnessSessionStore(customDirectory: temporaryDirectory)
        XCTAssertEqual(store.records.count, 0)
        
        let record = WellnessSessionRecord(
            activityType: .breathing,
            durationSeconds: 60.0,
            completionStatus: "Completed",
            ratingBefore: 2,
            ratingAfter: 4
        )
        
        store.save(record: record)
        XCTAssertEqual(store.records.count, 1)
        XCTAssertEqual(store.records.first?.ratingAfter, 4)
        
        // Reload from disk
        let store2 = WellnessSessionStore(customDirectory: temporaryDirectory)
        XCTAssertEqual(store2.records.count, 1)
        XCTAssertEqual(store2.records.first?.activityType, .breathing)
    }
    
    func testMotorAndWellnessDataIsolation() {
        let motorDir = temporaryDirectory.appendingPathComponent("Motor")
        let wellnessDir = temporaryDirectory.appendingPathComponent("Wellness")
        
        let motorStore = MotorSessionStore(customDirectory: motorDir)
        let wellnessStore = WellnessSessionStore(customDirectory: wellnessDir)
        
        motorStore.save(record: MotorSessionRecord(
            testType: .spiral,
            testedHand: "Left",
            durationSeconds: 12.0,
            primaryScoreLabel: "4.8% RMSE",
            primaryScoreValue: 4.8,
            secondaryScoreLabel: "1.02x length",
            qualityStatus: .valid
        ))
        
        XCTAssertEqual(motorStore.records.count, 1)
        XCTAssertEqual(wellnessStore.records.count, 0)
        
        wellnessStore.save(record: WellnessSessionRecord(
            activityType: .meditation,
            durationSeconds: 180.0,
            completionStatus: "Completed"
        ))
        
        XCTAssertEqual(motorStore.records.count, 1)
        XCTAssertEqual(wellnessStore.records.count, 1)
    }
}
