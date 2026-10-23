//
//  SessionStoreTests.swift
//  NeuroPulseAITests
//
//  Unit tests verifying isolated persistence of motor and wellness sessions,
//  two-zone deviation metrics storage, backward compatibility, and domain isolation.
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
            protocolVersion: "2.0",
            isSampleData: false,
            completionStatus: "Completed",
            meanCenterDeviationPoints: 4.25,
            meanNormalizedCenterDeviationPercent: 13.28,
            totalAttempts: 84,
            correctAlternatingTaps: 82,
            alternationAccuracyPercent: 97.62
        )
        
        store.save(record: record)
        XCTAssertEqual(store.records.count, 1)
        XCTAssertEqual(store.records.first?.id, record.id)
        
        // Instantiate a second store pointing to the exact same temporary directory
        let store2 = MotorSessionStore(customDirectory: temporaryDirectory)
        XCTAssertEqual(store2.records.count, 1)
        let loaded = store2.records.first!
        XCTAssertEqual(loaded.primaryScoreLabel, "5.5 Hz")
        XCTAssertEqual(loaded.testedHand, "Right")
        XCTAssertEqual(loaded.meanCenterDeviationPoints!, 4.25, accuracy: 0.001)
        XCTAssertEqual(loaded.meanNormalizedCenterDeviationPercent!, 13.28, accuracy: 0.001)
        XCTAssertEqual(loaded.totalAttempts, 84)
        XCTAssertEqual(loaded.correctAlternatingTaps, 82)
        XCTAssertEqual(loaded.alternationAccuracyPercent!, 97.62, accuracy: 0.01)
    }
    
    func testMotorSessionRecordBackwardCompatibility() throws {
        // Legacy JSON record from v1.0 without center-deviation fields
        let legacyJSON = """
        {
            "id": "A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D",
            "date": 750000000.0,
            "testType": "Finger Tapping",
            "testedHand": "Right",
            "durationSeconds": 15.0,
            "primaryScoreLabel": "5.4 Hz",
            "primaryScoreValue": 5.4,
            "secondaryScoreLabel": "81 taps",
            "qualityStatus": "Valid Session",
            "protocolVersion": "1.0",
            "isSampleData": false
        }
        """.data(using: .utf8)!
        
        let decoded = try JSONDecoder().decode(MotorSessionRecord.self, from: legacyJSON)
        XCTAssertEqual(decoded.testedHand, "Right")
        XCTAssertEqual(decoded.primaryScoreLabel, "5.4 Hz")
        XCTAssertEqual(decoded.completionStatus, "Completed")
        XCTAssertNil(decoded.meanCenterDeviationPoints)
        XCTAssertNil(decoded.totalAttempts)
    }
    
    func testMultipleSessionsAppendAndPreserveOrder() {
        let store = MotorSessionStore(customDirectory: temporaryDirectory)
        
        let now = Date()
        let olderRecord = MotorSessionRecord(
            date: now.addingTimeInterval(-3600),
            testType: .tapping,
            testedHand: "Right",
            durationSeconds: 15.0,
            primaryScoreLabel: "5.0 Hz",
            primaryScoreValue: 5.0,
            secondaryScoreLabel: "75 taps",
            qualityStatus: .valid
        )
        let newerRecord = MotorSessionRecord(
            date: now,
            testType: .spiral,
            testedHand: "Right",
            durationSeconds: 12.0,
            primaryScoreLabel: "5.5% RMSE",
            primaryScoreValue: 5.5,
            secondaryScoreLabel: "1.03x length",
            qualityStatus: .valid
        )
        
        store.save(record: olderRecord)
        store.save(record: newerRecord)
        
        XCTAssertEqual(store.records.count, 2)
        // Reverse chronological: newer record first
        XCTAssertEqual(store.records[0].id, newerRecord.id)
        XCTAssertEqual(store.records[1].id, olderRecord.id)
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
