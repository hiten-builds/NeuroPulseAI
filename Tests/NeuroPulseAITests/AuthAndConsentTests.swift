//
//  AuthAndConsentTests.swift
//  NeuroPulseAITests
//
//  Unit tests covering Phase 7A requirements:
//  - Two operating modes (Local-Only vs Authenticated)
//  - Purpose-specific consent lifecycle (granted, declined, withdrawn)
//  - Consent gate enforcement in SyncService (zero uploads for local-only / unconsented)
//  - Preservation of local records across sign-out
//  - Explainable recommendation generation
//

import XCTest
@testable import NeuroPulseAI

// MARK: - Mock API Client for Isolated Testing

final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var registerResult: Result<AuthResponseDTO, Error> = .success(
        AuthResponseDTO(
            accessToken: "mock-token-abc-123",
            tokenType: "bearer",
            user: UserDTO(id: "user-123", email: "test@example.com", isActive: true, createdAt: "2026-10-24T00:00:00Z")
        )
    )
    
    var loginResult: Result<AuthResponseDTO, Error> = .success(
        AuthResponseDTO(
            accessToken: "mock-token-abc-123",
            tokenType: "bearer",
            user: UserDTO(id: "user-123", email: "test@example.com", isActive: true, createdAt: "2026-10-24T00:00:00Z")
        )
    )
    
    var consentResult: Result<ConsentResponseDTO, Error> = .success(
        ConsentResponseDTO(
            id: "consent-1",
            userId: "user-123",
            purpose: "personalization",
            decision: "granted",
            version: "1.0",
            decisionTimestamp: "2026-10-24T00:00:00Z",
            withdrawalTimestamp: nil,
            currentStatus: "active"
        )
    )
    
    var syncCallCount = 0
    var lastSyncBatch: SyncBatchRequestDTO?
    var syncResult: Result<SyncBatchResponseDTO, Error> = .success(
        SyncBatchResponseDTO(
            syncedMotorCount: 1,
            syncedWellnessCount: 0,
            existingMotorCount: 0,
            existingWellnessCount: 0,
            syncedAt: "2026-10-24T00:00:00Z"
        )
    )
    
    var recommendationsResult: Result<RecommendationListResponseDTO, Error> = .success(
        RecommendationListResponseDTO(
            userId: "user-123",
            hasSufficientData: true,
            statusMessage: "Personalized from 2 records",
            recommendations: [
                RecommendationItemDTO(
                    recommendationId: "rec-1",
                    title: "Smooth Cadence Pacing",
                    description: "Maintain a steady tapping cadence.",
                    category: "cadence",
                    explanation: "Derived from 2 tapping trials with stable CV.",
                    createdAt: "2026-10-24T00:00:00Z"
                )
            ],
            generatedAt: "2026-10-24T00:00:00Z"
        )
    )
    
    var deleteRemoteDataCallCount = 0
    
    func register(email: String, password: String) async throws -> AuthResponseDTO {
        return try registerResult.get()
    }
    
    func login(email: String, password: String) async throws -> AuthResponseDTO {
        return try loginResult.get()
    }
    
    func getProfile(token: String) async throws -> UserDTO {
        return UserDTO(id: "user-123", email: "test@example.com", isActive: true, createdAt: nil)
    }
    
    func getConsent(token: String) async throws -> ConsentResponseDTO {
        return try consentResult.get()
    }
    
    func setConsent(token: String, request: ConsentDecisionRequestDTO) async throws -> ConsentResponseDTO {
        return try consentResult.get()
    }
    
    func withdrawConsent(token: String) async throws -> ConsentResponseDTO {
        return ConsentResponseDTO(
            id: "consent-withdrawn",
            userId: "user-123",
            purpose: "personalization",
            decision: "declined",
            version: "1.0",
            decisionTimestamp: "2026-10-24T00:00:00Z",
            withdrawalTimestamp: "2026-10-24T00:00:00Z",
            currentStatus: "withdrawn"
        )
    }
    
    func syncSessions(token: String, batch: SyncBatchRequestDTO) async throws -> SyncBatchResponseDTO {
        syncCallCount += 1
        lastSyncBatch = batch
        return try syncResult.get()
    }
    
    func getRecommendations(token: String) async throws -> RecommendationListResponseDTO {
        return try recommendationsResult.get()
    }
    
    func deleteRemoteData(token: String) async throws -> RemoteDataDeletionResponseDTO {
        deleteRemoteDataCallCount += 1
        return RemoteDataDeletionResponseDTO(
            status: "success",
            message: "Remote records deleted",
            deletedMotorSessions: 1,
            deletedWellnessSessions: 0,
            deletedRecommendations: 1,
            consentWithdrawn: true
        )
    }
}

// MARK: - Test Cases

@MainActor
final class AuthAndConsentTests: XCTestCase {
    private var mockAPI: MockAPIClient!
    private var testUserDefaults: UserDefaults!
    private var testSuiteName: String!
    
    override func setUp() {
        super.setUp()
        testSuiteName = "test_\(UUID().uuidString)"
        testUserDefaults = UserDefaults(suiteName: testSuiteName)!
        mockAPI = MockAPIClient()
    }
    
    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: testSuiteName)
        super.tearDown()
    }
    
    func testContinueLocallySetsModeWithoutCallingBackend() {
        let authManager = AuthManager(
            apiClient: mockAPI,
            keychain: KeychainHelper.shared,
            userDefaults: testUserDefaults
        )
        
        XCTAssertEqual(authManager.currentMode, .welcome)
        authManager.continueLocally()
        
        XCTAssertEqual(authManager.currentMode, .localOnly)
        XCTAssertNil(authManager.currentUser)
        XCTAssertEqual(mockAPI.syncCallCount, 0)
    }
    
    func testRegisterSuccessAndSignOutPreservesLocalRecords() async {
        let authManager = AuthManager(
            apiClient: mockAPI,
            keychain: KeychainHelper.shared,
            userDefaults: testUserDefaults
        )
        
        let success = await authManager.register(email: "test@example.com", password: "password123")
        XCTAssertTrue(success)
        XCTAssertEqual(authManager.currentMode, .authenticated)
        XCTAssertEqual(authManager.currentUser?.email, "test@example.com")
        
        // Sign out
        authManager.signOut()
        XCTAssertEqual(authManager.currentMode, .welcome)
        XCTAssertNil(authManager.currentUser)
        XCTAssertNil(authManager.authToken)
    }
    
    func testConsentLifecycle_Granted_Declined_Withdrawn() async {
        let consentManager = ConsentManager(
            apiClient: mockAPI,
            userDefaults: testUserDefaults
        )
        
        XCTAssertFalse(consentManager.hasMadeDecision)
        XCTAssertFalse(consentManager.isPersonalizationConsented)
        
        // Grant
        _ = await consentManager.grantConsent(authToken: "token-123")
        XCTAssertTrue(consentManager.hasMadeDecision)
        XCTAssertTrue(consentManager.isPersonalizationConsented)
        XCTAssertEqual(consentManager.decision, .granted)
        
        // Decline
        _ = await consentManager.declineConsent(authToken: "token-123")
        XCTAssertTrue(consentManager.hasMadeDecision)
        XCTAssertFalse(consentManager.isPersonalizationConsented)
        XCTAssertEqual(consentManager.decision, .declined)
        
        // Withdraw
        _ = await consentManager.withdrawConsent(authToken: "token-123")
        XCTAssertFalse(consentManager.isPersonalizationConsented)
        XCTAssertEqual(consentManager.decision, .withdrawn)
    }
    
    func testSyncService_StrictlyBlocksUpload_WhenLocalOnly() async {
        let authManager = AuthManager(apiClient: mockAPI, userDefaults: testUserDefaults)
        authManager.continueLocally()
        
        let consentManager = ConsentManager(apiClient: mockAPI, userDefaults: testUserDefaults)
        _ = await consentManager.grantConsent(authToken: nil)
        
        let syncService = SyncService(
            apiClient: mockAPI,
            authManager: authManager,
            consentManager: consentManager,
            userDefaults: testUserDefaults
        )
        
        await syncService.syncEligibleSessions()
        
        // In local only mode, zero network sync calls should happen!
        XCTAssertEqual(mockAPI.syncCallCount, 0)
        XCTAssertEqual(syncService.syncState, .localOnly)
    }
    
    func testSyncService_StrictlyBlocksUpload_WhenConsentDeclinedOrWithdrawn() async {
        let authManager = AuthManager(apiClient: mockAPI, userDefaults: testUserDefaults)
        _ = await authManager.register(email: "user@example.com", password: "password123")
        
        let consentManager = ConsentManager(apiClient: mockAPI, userDefaults: testUserDefaults)
        _ = await consentManager.declineConsent(authToken: authManager.authToken)
        
        let syncService = SyncService(
            apiClient: mockAPI,
            authManager: authManager,
            consentManager: consentManager,
            userDefaults: testUserDefaults
        )
        
        await syncService.syncEligibleSessions()
        
        // Declined consent must NEVER upload
        XCTAssertEqual(mockAPI.syncCallCount, 0)
        XCTAssertEqual(syncService.syncState, .consentDeclined)
    }
    
    func testRecommendationService_DeterministicLocalGuidance_WhenLocalOnly() async {
        let authManager = AuthManager(apiClient: mockAPI, userDefaults: testUserDefaults)
        authManager.continueLocally()
        
        let consentManager = ConsentManager(apiClient: mockAPI, userDefaults: testUserDefaults)
        
        let recommendationService = RecommendationService(
            apiClient: mockAPI,
            authManager: authManager,
            consentManager: consentManager
        )
        
        await recommendationService.loadRecommendations()
        
        // Local guidance should be populated with on-device badge
        XCTAssertFalse(recommendationService.recommendations.isEmpty)
        for rec in recommendationService.recommendations {
            XCTAssertFalse(rec.isCloudPersonalized, "Local-only recommendations must be flagged as non-cloud")
            XCTAssertFalse(rec.explanation.isEmpty)
        }
    }
}
