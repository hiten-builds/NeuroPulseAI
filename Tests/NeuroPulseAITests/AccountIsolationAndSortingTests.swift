//
//  AccountIsolationAndSortingTests.swift
//  NeuroPulseAITests
//
//  Comprehensive automated regression tests for:
//  1. Activity History deterministic newest-first sorting (timestamp + tie-breaker)
//  2. Account-scoped activity history isolation (Account A vs Account B vs Legacy)
//  3. Terms & Conditions per-account acceptance & versioning
//  4. Data-sharing consent per-account isolation
//  5. Logout and account switching lifecycle (memory reset without data destruction)
//  6. Deterministic CSV export ordering
//

import XCTest
@testable import NeuroPulseAI

@MainActor
final class AccountIsolationAndSortingTests: XCTestCase {
    var temporaryDirectory: URL!
    var userDefaultsSuite: UserDefaults!
    var userDefaultsSuiteName: String!
    
    override func setUp() {
        super.setUp()
        temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("NeuroPulseAITests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        
        userDefaultsSuiteName = "test_suite_\(UUID().uuidString)"
        userDefaultsSuite = UserDefaults(suiteName: userDefaultsSuiteName)!
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: temporaryDirectory)
        userDefaultsSuite.removePersistentDomain(forName: userDefaultsSuiteName)
        super.tearDown()
    }
    
    // MARK: - 1. Activity History Sorting Tests
    
    func testHistorySortingDescendingChronological() {
        let store = MotorSessionStore(customDirectory: temporaryDirectory)
        let baseDate = Date(timeIntervalSince1970: 1700000000)
        
        // Out of order: 10:00, 08:00, 11:00, 09:00
        let date08 = baseDate.addingTimeInterval(8 * 3600)
        let date09 = baseDate.addingTimeInterval(9 * 3600)
        let date10 = baseDate.addingTimeInterval(10 * 3600)
        let date11 = baseDate.addingTimeInterval(11 * 3600)
        
        let rec10 = MotorSessionRecord(date: date10, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "10:00", primaryScoreValue: 10.0, secondaryScoreLabel: "80 taps", qualityStatus: .valid)
        let rec08 = MotorSessionRecord(date: date08, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "08:00", primaryScoreValue: 8.0, secondaryScoreLabel: "70 taps", qualityStatus: .valid)
        let rec11 = MotorSessionRecord(date: date11, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "11:00", primaryScoreValue: 11.0, secondaryScoreLabel: "85 taps", qualityStatus: .valid)
        let rec09 = MotorSessionRecord(date: date09, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "09:00", primaryScoreValue: 9.0, secondaryScoreLabel: "75 taps", qualityStatus: .valid)
        
        // Save in arbitrary order
        store.save(record: rec10)
        store.save(record: rec08)
        store.save(record: rec11)
        store.save(record: rec09)
        
        let records = store.records
        XCTAssertEqual(records.count, 4)
        
        // Expected order: Newest (11:00) -> 10:00 -> 09:00 -> Oldest (08:00)
        XCTAssertEqual(records[0].date, date11)
        XCTAssertEqual(records[1].date, date10)
        XCTAssertEqual(records[2].date, date09)
        XCTAssertEqual(records[3].date, date08)
    }
    
    func testHistorySortingWithIdenticalTimestampsHasDeterministicTieBreaker() {
        let store = MotorSessionStore(customDirectory: temporaryDirectory)
        let exactSameDate = Date(timeIntervalSince1970: 1700000000)
        
        let idA = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let idB = UUID(uuidString: "99999999-9999-9999-9999-999999999999")!
        
        let recA = MotorSessionRecord(id: idA, date: exactSameDate, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "A", primaryScoreValue: 5.0, secondaryScoreLabel: "75 taps", qualityStatus: .valid)
        let recB = MotorSessionRecord(id: idB, date: exactSameDate, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "B", primaryScoreValue: 6.0, secondaryScoreLabel: "80 taps", qualityStatus: .valid)
        
        store.save(record: recA)
        store.save(record: recB)
        
        let records = store.records
        XCTAssertEqual(records.count, 2)
        // With identical timestamps, tie-breaker must place larger UUID string first deterministically
        XCTAssertEqual(records[0].id, idB)
        XCTAssertEqual(records[1].id, idA)
    }
    
    func testHistorySortingSurvivesPersistenceRelaunch() {
        let store1 = MotorSessionStore(customDirectory: temporaryDirectory)
        let baseDate = Date()
        
        let older = MotorSessionRecord(date: baseDate.addingTimeInterval(-7200), testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "Older", primaryScoreValue: 4.0, secondaryScoreLabel: "60 taps", qualityStatus: .valid)
        let newer = MotorSessionRecord(date: baseDate.addingTimeInterval(-60), testType: .spiral, testedHand: "Right", durationSeconds: 12.0, primaryScoreLabel: "Newer", primaryScoreValue: 5.0, secondaryScoreLabel: "1.02x", qualityStatus: .valid)
        
        store1.save(record: older)
        store1.save(record: newer)
        
        // Create brand new store instance simulating app restart
        let store2 = MotorSessionStore(customDirectory: temporaryDirectory)
        XCTAssertEqual(store2.records.count, 2)
        XCTAssertEqual(store2.records[0].primaryScoreLabel, "Newer")
        XCTAssertEqual(store2.records[1].primaryScoreLabel, "Older")
    }
    
    func testWellnessSortingDescendingChronological() {
        let store = WellnessSessionStore(customDirectory: temporaryDirectory)
        let now = Date()
        
        let session1 = WellnessSessionRecord(date: now.addingTimeInterval(-1800), activityType: .breathing, durationSeconds: 120, completionStatus: "Completed", ratingBefore: 4, ratingAfter: 2)
        let session2 = WellnessSessionRecord(date: now.addingTimeInterval(-600), activityType: .meditation, durationSeconds: 180, completionStatus: "Completed", ratingBefore: 5, ratingAfter: 1)
        
        store.save(record: session1)
        store.save(record: session2)
        
        XCTAssertEqual(store.records.count, 2)
        XCTAssertEqual(store.activityTypeFirst(), .meditation)
    }
    
    // MARK: - 2. Account Isolation Tests
    
    func testAccountIsolationAcrossStores() {
        let store = MotorSessionStore(customDirectory: temporaryDirectory)
        let accountA = "user-account-aaa"
        let accountB = "user-account-bbb"
        
        let now = Date()
        let sessionA1 = MotorSessionRecord(accountID: accountA, date: now.addingTimeInterval(-300), testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "A1", primaryScoreValue: 5.0, secondaryScoreLabel: "Taps", qualityStatus: .valid)
        let sessionA2 = MotorSessionRecord(accountID: accountA, date: now.addingTimeInterval(-100), testType: .spiral, testedHand: "Right", durationSeconds: 14.0, primaryScoreLabel: "A2", primaryScoreValue: 6.0, secondaryScoreLabel: "Spiral", qualityStatus: .valid)
        let sessionB1 = MotorSessionRecord(accountID: accountB, date: now.addingTimeInterval(-50), testType: .tapping, testedHand: "Left", durationSeconds: 15.0, primaryScoreLabel: "B1", primaryScoreValue: 7.0, secondaryScoreLabel: "Taps", qualityStatus: .valid)
        
        store.save(record: sessionA1)
        store.save(record: sessionA2)
        store.save(record: sessionB1)
        
        // Fetch for Account A
        let recordsA = store.records(for: accountA)
        XCTAssertEqual(recordsA.count, 2)
        XCTAssertTrue(recordsA.contains(where: { $0.id == sessionA1.id }))
        XCTAssertTrue(recordsA.contains(where: { $0.id == sessionA2.id }))
        XCTAssertFalse(recordsA.contains(where: { $0.id == sessionB1.id }), "Account A must NEVER contain Account B records!")
        
        // Fetch for Account B
        let recordsB = store.records(for: accountB)
        XCTAssertEqual(recordsB.count, 1)
        XCTAssertEqual(recordsB[0].id, sessionB1.id)
        XCTAssertFalse(recordsB.contains(where: { $0.id == sessionA1.id }), "Account B must NEVER contain Account A records!")
        XCTAssertFalse(recordsB.contains(where: { $0.id == sessionA2.id }))
    }
    
    func testClearAllOnlyWipesActiveAccount() {
        let store = MotorSessionStore(customDirectory: temporaryDirectory)
        let accountA = "user-account-aaa"
        let accountB = "user-account-bbb"
        
        let sessionA = MotorSessionRecord(accountID: accountA, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "A", primaryScoreValue: 5.0, secondaryScoreLabel: "Taps", qualityStatus: .valid)
        let sessionB = MotorSessionRecord(accountID: accountB, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "B", primaryScoreValue: 5.0, secondaryScoreLabel: "Taps", qualityStatus: .valid)
        
        store.save(record: sessionA)
        store.save(record: sessionB)
        
        // Set active account to A and clear
        store.reload(for: accountA)
        XCTAssertEqual(store.records.count, 1)
        store.clearAll()
        XCTAssertEqual(store.records.count, 0)
        
        // Switch to Account B: B's data must remain intact!
        store.reload(for: accountB)
        XCTAssertEqual(store.records.count, 1)
        XCTAssertEqual(store.records.first?.id, sessionB.id)
    }
    
    func testLegacyUnattributedRecordsIsolation() {
        let store = MotorSessionStore(customDirectory: temporaryDirectory)
        let accountA = "user-account-aaa"
        
        // Legacy record created without account ID
        let legacyRecord = MotorSessionRecord(accountID: nil, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "Legacy", primaryScoreValue: 5.0, secondaryScoreLabel: "Taps", qualityStatus: .valid)
        let accountARecord = MotorSessionRecord(accountID: accountA, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "Account A", primaryScoreValue: 5.0, secondaryScoreLabel: "Taps", qualityStatus: .valid)
        
        store.save(record: legacyRecord)
        store.save(record: accountARecord)
        
        // When user A is active, legacy records must NOT appear in user A's history
        store.reload(for: accountA)
        XCTAssertEqual(store.records.count, 1)
        XCTAssertEqual(store.records[0].id, accountARecord.id)
        
        // In local-only mode (accountID == nil), only legacy/local records appear
        store.reload(for: nil)
        XCTAssertEqual(store.records.count, 1)
        XCTAssertEqual(store.records[0].id, legacyRecord.id)
    }
    
    // MARK: - 3. Terms & Conditions Acceptance Tests
    
    func testTermsAcceptancePerAccountIsolation() {
        let terms = TermsManager(userDefaults: userDefaultsSuite)
        let accountA = "user-111"
        let accountB = "user-222"
        
        XCTAssertFalse(terms.hasAcceptedCurrentTerms(accountID: accountA))
        XCTAssertFalse(terms.hasAcceptedCurrentTerms(accountID: accountB))
        
        // Account A accepts terms
        terms.acceptTerms(accountID: accountA)
        
        XCTAssertTrue(terms.hasAcceptedCurrentTerms(accountID: accountA))
        XCTAssertFalse(terms.hasAcceptedCurrentTerms(accountID: accountB), "Account B must NOT inherit Account A's terms acceptance!")
    }
    
    func testTermsVersioningRequiresRepromptOnUpgrade() {
        let terms = TermsManager(userDefaults: userDefaultsSuite)
        let accountA = "user-111"
        
        // Simulate previous acceptance of an older version (e.g. "2025-01-01")
        userDefaultsSuite.set("2025-01-01", forKey: "neuropulse_terms_version_\(accountA)")
        
        // Since current version is "2026-10-24", hasAcceptedCurrentTerms must return false
        XCTAssertFalse(terms.hasAcceptedCurrentTerms(accountID: accountA))
        
        // Accepting current version updates it
        terms.acceptTerms(accountID: accountA)
        XCTAssertTrue(terms.hasAcceptedCurrentTerms(accountID: accountA))
    }
    
    // MARK: - 4. Data-Sharing Consent Isolation Tests
    
    func testConsentPerAccountIsolation() async {
        let consent = ConsentManager(userDefaults: userDefaultsSuite)
        let accountA = "user-aaa"
        let accountB = "user-bbb"
        
        // Initially both undecided
        XCTAssertEqual(consent.decision(for: accountA), .undecided)
        XCTAssertEqual(consent.decision(for: accountB), .undecided)
        
        // Account A grants consent
        consent.loadForAccount(accountID: accountA)
        _ = await consent.grantConsent(authToken: nil, accountID: accountA)
        
        XCTAssertEqual(consent.decision(for: accountA), .granted)
        XCTAssertEqual(consent.decision(for: accountB), .undecided, "Account B must NOT inherit Account A's consent!")
        
        // Account B declines consent
        consent.loadForAccount(accountID: accountB)
        _ = await consent.declineConsent(authToken: nil, accountID: accountB)
        
        XCTAssertEqual(consent.decision(for: accountA), .granted)
        XCTAssertEqual(consent.decision(for: accountB), .declined)
    }
    
    // MARK: - 5. Logout & Account Switching Lifecycle Tests
    
    func testAccountSwitchingLifecycle() async {
        let motorStore = MotorSessionStore(customDirectory: temporaryDirectory)
        let consent = ConsentManager(userDefaults: userDefaultsSuite)
        let terms = TermsManager(userDefaults: userDefaultsSuite)
        
        let accountA = "user-aaa"
        let accountB = "user-bbb"
        
        // --- 1. Login Account A ---
        motorStore.reload(for: accountA)
        consent.loadForAccount(accountID: accountA)
        terms.loadForAccount(accountID: accountA)
        
        terms.acceptTerms(accountID: accountA)
        _ = await consent.grantConsent(authToken: nil, accountID: accountA)
        let recA = MotorSessionRecord(accountID: accountA, testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "5.5 Hz", primaryScoreValue: 5.5, secondaryScoreLabel: "80 taps", qualityStatus: .valid)
        motorStore.save(record: recA)
        
        XCTAssertEqual(motorStore.records.count, 1)
        XCTAssertEqual(consent.decision, .granted)
        XCTAssertTrue(terms.isAccepted)
        
        // --- 2. Sign Out ---
        motorStore.reload(for: nil)
        consent.resetForSignOut()
        terms.resetForSignOut()
        
        XCTAssertEqual(motorStore.records.count, 0)
        XCTAssertEqual(consent.decision, .undecided)
        XCTAssertFalse(terms.isAccepted)
        
        // --- 3. Login Account B ---
        motorStore.reload(for: accountB)
        consent.loadForAccount(accountID: accountB)
        terms.loadForAccount(accountID: accountB)
        
        // Account B must see clean, isolated state
        XCTAssertEqual(motorStore.records.count, 0, "Account B must see 0 records initially!")
        XCTAssertEqual(consent.decision, .undecided, "Account B must not have consent!")
        XCTAssertFalse(terms.isAccepted, "Account B must not have accepted terms!")
        
        // Account B accepts terms, declines consent, and saves a session
        terms.acceptTerms(accountID: accountB)
        _ = await consent.declineConsent(authToken: nil, accountID: accountB)
        let recB = MotorSessionRecord(accountID: accountB, testType: .spiral, testedHand: "Right", durationSeconds: 12.0, primaryScoreLabel: "6.0% RMSE", primaryScoreValue: 6.0, secondaryScoreLabel: "Spiral", qualityStatus: .valid)
        motorStore.save(record: recB)
        
        XCTAssertEqual(motorStore.records.count, 1)
        XCTAssertEqual(motorStore.records[0].id, recB.id)
        
        // --- 4. Switch back to Account A ---
        motorStore.reload(for: nil)
        consent.resetForSignOut()
        terms.resetForSignOut()
        
        motorStore.reload(for: accountA)
        consent.loadForAccount(accountID: accountA)
        terms.loadForAccount(accountID: accountA)
        
        // Account A's state must be completely preserved!
        XCTAssertEqual(motorStore.records.count, 1)
        XCTAssertEqual(motorStore.records[0].id, recA.id)
        XCTAssertEqual(consent.decision, .granted)
        XCTAssertTrue(terms.isAccepted)
    }
    
    // MARK: - 6. SessionExportService Sorting Test
    
    func testSessionExportServiceSortsNewestFirst() {
        let baseDate = Date(timeIntervalSince1970: 1700000000)
        let recOlder = MotorSessionRecord(date: baseDate.addingTimeInterval(-3600), testType: .tapping, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "Older", primaryScoreValue: 5.0, secondaryScoreLabel: "Taps", qualityStatus: .valid)
        let recNewer = MotorSessionRecord(date: baseDate.addingTimeInterval(-60), testType: .spiral, testedHand: "Right", durationSeconds: 15.0, primaryScoreLabel: "Newer", primaryScoreValue: 6.0, secondaryScoreLabel: "Spiral", qualityStatus: .valid)
        
        // Pass in older first
        let csv = SessionExportService.generateCSV(from: [recOlder, recNewer])
        let rows = csv.components(separatedBy: "\r\n")
        
        // Row 0 is header, Row 1 should be Newer, Row 2 should be Older
        XCTAssertTrue(rows.count >= 3)
        XCTAssertTrue(rows[1].contains("Newer"), "Row 1 must be the newer record!")
        XCTAssertTrue(rows[2].contains("Older"), "Row 2 must be the older record!")
    }
}

private extension WellnessSessionStore {
    func activityTypeFirst() -> WellnessActivityType? {
        return records.first?.activityType
    }
}
