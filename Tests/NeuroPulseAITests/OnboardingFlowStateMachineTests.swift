//
//  OnboardingFlowStateMachineTests.swift
//  NeuroPulseAITests
//
//  Automated unit and integration tests for the non-blocking onboarding & consent checkpoint:
//  - Phase 19: Terms & Conditions blocking requirements
//  - Phase 20: Data-Sharing Consent blocking requirements
//  - Phase 21: Full state-machine flow integration
//  - Phase 22: Account-isolation regression
//  - Phase 25: App relaunch while Terms is required
//  - Phase 26: App relaunch while Consent is required
//

import XCTest
@testable import NeuroPulseAI

@MainActor
final class OnboardingFlowStateMachineTests: XCTestCase {
    private var mockAPI: MockAPIClient!
    private var testUserDefaults: UserDefaults!
    private var testSuiteName: String!
    private var termsManager: TermsManager!
    private var consentManager: ConsentManager!
    
    override func setUp() {
        super.setUp()
        testSuiteName = "test_onboarding_\(UUID().uuidString)"
        testUserDefaults = UserDefaults(suiteName: testSuiteName)!
        mockAPI = MockAPIClient()
        termsManager = TermsManager(userDefaults: testUserDefaults)
        consentManager = ConsentManager(apiClient: mockAPI, userDefaults: testUserDefaults)
    }
    
    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: testSuiteName)
        super.tearDown()
    }
    
    private func createAuthManager() -> AuthManager {
        return AuthManager(
            apiClient: mockAPI,
            keychain: KeychainHelper.shared,
            userDefaults: testUserDefaults,
            termsManager: termsManager,
            consentManager: consentManager
        )
    }
    
    // MARK: - PHASE 19: Terms Tests
    
    /// Test 1 — New account requires Terms (acceptedTermsVersion = nil -> TermsRequired)
    func testNewAccountRequiresTerms() async {
        let auth = createAuthManager()
        
        let success = await auth.register(email: "newuser@example.com", password: "password123")
        XCTAssertTrue(success)
        XCTAssertEqual(auth.currentMode, .authenticated)
        
        let accountID = auth.currentUser?.id
        XCTAssertNil(termsManager.acceptedVersion(for: accountID))
        XCTAssertFalse(termsManager.hasAcceptedCurrentTerms(accountID: accountID))
        
        // Root flow must be strictly blocked at termsRequired
        XCTAssertEqual(auth.flowState, .termsRequired)
    }
    
    /// Test 2 — Current Terms accepted (acceptedTermsVersion = currentTermsVersion -> Terms not required)
    func testCurrentTermsAcceptedDoesNotRequireTerms() async {
        let auth = createAuthManager()
        let accountID = "existing-user-123"
        
        // Pre-accept current terms
        termsManager.acceptTerms(accountID: accountID)
        XCTAssertTrue(termsManager.hasAcceptedCurrentTerms(accountID: accountID))
        
        // Also pre-decide consent to test ready state
        consentManager.loadForAccount(accountID: accountID)
        _ = await consentManager.grantConsent(authToken: nil, accountID: accountID)
        
        mockAPI.loginResult = .success(
            AuthResponseDTO(
                accessToken: "token-123",
                tokenType: "bearer",
                user: UserDTO(id: accountID, email: "user@example.com", isActive: true, createdAt: nil)
            )
        )
        
        let success = await auth.signIn(email: "user@example.com", password: "password123")
        XCTAssertTrue(success)
        
        // Since terms and consent are already satisfied, should advance straight to ready
        XCTAssertEqual(auth.flowState, .ready)
    }
    
    /// Test 3 — Old Terms version (acceptedTermsVersion = oldVersion -> TermsRequired)
    func testOldTermsVersionRequiresTerms() async {
        let auth = createAuthManager()
        let accountID = "user-old-terms"
        
        // Simulate previous acceptance of an outdated terms version
        testUserDefaults.set("2025-01-01", forKey: "neuropulse_terms_version_\(accountID)")
        testUserDefaults.set(Date().timeIntervalSince1970, forKey: "neuropulse_terms_date_\(accountID)")
        
        mockAPI.loginResult = .success(
            AuthResponseDTO(
                accessToken: "token-123",
                tokenType: "bearer",
                user: UserDTO(id: accountID, email: "oldterms@example.com", isActive: true, createdAt: nil)
            )
        )
        
        let success = await auth.signIn(email: "oldterms@example.com", password: "password123")
        XCTAssertTrue(success)
        
        // Outdated terms must trigger termsRequired checkpoint
        XCTAssertFalse(termsManager.hasAcceptedCurrentTerms(accountID: accountID))
        XCTAssertEqual(auth.flowState, .termsRequired)
    }
    
    /// Test 4 — Showing Terms does NOT complete requirement (Presentation is not completion)
    func testShowingTermsDoesNotCompleteRequirement() async {
        let auth = createAuthManager()
        
        let success = await auth.register(email: "viewer@example.com", password: "password123")
        XCTAssertTrue(success)
        XCTAssertEqual(auth.flowState, .termsRequired)
        
        // Simulate screen presentation / lifecycle events / waiting 15 seconds
        // Neither reading nor re-evaluating should mark terms complete
        termsManager.loadForAccount(accountID: auth.currentUser?.id)
        auth.evaluateOnboardingRequirements()
        
        XCTAssertFalse(termsManager.hasAcceptedCurrentTerms(accountID: auth.currentUser?.id))
        XCTAssertEqual(auth.flowState, .termsRequired, "Merely showing or waiting on Terms screen must NEVER advance flowState!")
    }
    
    /// Test 5 — Accept completes Terms (tap Accept -> persisted -> state advances)
    func testAcceptCompletesTermsAndAdvances() async {
        let auth = createAuthManager()
        
        _ = await auth.register(email: "acceptor@example.com", password: "password123")
        XCTAssertEqual(auth.flowState, .termsRequired)
        
        // User explicitly taps "Agree & Continue"
        auth.acceptTermsAndAdvance()
        
        let accountID = auth.currentUser?.id
        XCTAssertTrue(termsManager.hasAcceptedCurrentTerms(accountID: accountID))
        XCTAssertEqual(termsManager.acceptedVersion(for: accountID), TermsManager.currentTermsVersion)
        
        // Should advance to consentRequired (since consent is still undecided)
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
    }
    
    // MARK: - PHASE 20: Consent Tests
    
    /// Test 1 — New account requires consent (consent = notDetermined -> DataSharingConsentRequired)
    func testNewAccountRequiresConsent() async {
        let auth = createAuthManager()
        
        _ = await auth.register(email: "consentuser@example.com", password: "password123")
        auth.acceptTermsAndAdvance()
        
        let accountID = auth.currentUser?.id
        XCTAssertEqual(consentManager.decision(for: accountID), .undecided)
        XCTAssertFalse(consentManager.hasMadeDecision(for: accountID))
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
    }
    
    /// Test 2 — Allow completes consent (Allow -> consent = allowed -> state = ready)
    func testAllowConsentCompletesRequirementAndAdvancesToReady() async {
        let auth = createAuthManager()
        
        _ = await auth.register(email: "allowuser@example.com", password: "password123")
        auth.acceptTermsAndAdvance()
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
        
        // User taps "Allow Data Sharing for Personalization"
        let success = await auth.recordConsentDecisionAndAdvance(granted: true)
        XCTAssertTrue(success)
        
        let accountID = auth.currentUser?.id
        XCTAssertEqual(consentManager.decision(for: accountID), .granted)
        XCTAssertTrue(consentManager.hasMadeDecision(for: accountID))
        XCTAssertEqual(auth.flowState, .ready)
    }
    
    /// Test 3 — Deny completes consent (Do Not Allow -> consent = denied -> state = ready)
    func testDenyConsentCompletesRequirementAndAdvancesToReady() async {
        let auth = createAuthManager()
        
        _ = await auth.register(email: "denyuser@example.com", password: "password123")
        auth.acceptTermsAndAdvance()
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
        
        // User taps "Decline & Keep Data Local Only"
        let success = await auth.recordConsentDecisionAndAdvance(granted: false)
        XCTAssertTrue(success)
        
        let accountID = auth.currentUser?.id
        XCTAssertEqual(consentManager.decision(for: accountID), .declined)
        XCTAssertTrue(consentManager.hasMadeDecision(for: accountID))
        // Explicit denial is a completed decision, so application proceeds to ready
        XCTAssertEqual(auth.flowState, .ready)
    }
    
    /// Test 4 — Showing consent does NOT complete it (consent remains notDetermined -> application remains blocked)
    func testShowingConsentDoesNotCompleteRequirement() async {
        let auth = createAuthManager()
        
        _ = await auth.register(email: "consentviewer@example.com", password: "password123")
        auth.acceptTermsAndAdvance()
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
        
        // Simulate lifecycle / 15-second wait
        consentManager.loadForAccount(accountID: auth.currentUser?.id)
        auth.evaluateOnboardingRequirements()
        
        XCTAssertEqual(consentManager.decision(for: auth.currentUser?.id), .undecided)
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired, "Merely displaying the consent screen must NEVER advance flowState!")
    }
    
    // MARK: - PHASE 21: Full Flow Integration Tests
    
    /// Test Flow A: Register -> TermsRequired -> Accept -> ConsentRequired -> Allow -> Ready
    func testFlow_Register_AcceptTerms_AllowConsent_Ready() async {
        let auth = createAuthManager()
        
        XCTAssertEqual(auth.flowState, .welcome)
        
        // 1. Register
        let registered = await auth.register(email: "flow_a@example.com", password: "password123")
        XCTAssertTrue(registered)
        XCTAssertEqual(auth.flowState, .termsRequired)
        
        // 2. Accept Terms
        auth.acceptTermsAndAdvance()
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
        
        // 3. Allow Consent
        let consentGranted = await auth.recordConsentDecisionAndAdvance(granted: true)
        XCTAssertTrue(consentGranted)
        XCTAssertEqual(auth.flowState, .ready)
    }
    
    /// Test Flow B: Register -> TermsRequired -> Accept -> ConsentRequired -> Deny -> Ready
    func testFlow_Register_AcceptTerms_DenyConsent_Ready() async {
        let auth = createAuthManager()
        
        XCTAssertEqual(auth.flowState, .welcome)
        
        // 1. Register
        let registered = await auth.register(email: "flow_b@example.com", password: "password123")
        XCTAssertTrue(registered)
        XCTAssertEqual(auth.flowState, .termsRequired)
        
        // 2. Accept Terms
        auth.acceptTermsAndAdvance()
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
        
        // 3. Decline Consent
        let consentDeclined = await auth.recordConsentDecisionAndAdvance(granted: false)
        XCTAssertTrue(consentDeclined)
        XCTAssertEqual(auth.flowState, .ready)
    }
    
    // MARK: - PHASE 22: Account Isolation Regression Tests
    
    /// Test Account Isolation: Account A (complete) vs Account B (new/incomplete)
    func testAccountIsolation_AccountB_DoesNotInheritAccountA_State() async {
        let auth = createAuthManager()
        let accountA = "user-acc-aaa"
        let accountB = "user-acc-bbb"
        
        // Pre-configure Account A: Terms accepted + Consent allowed
        termsManager.acceptTerms(accountID: accountA)
        _ = await consentManager.grantConsent(authToken: nil, accountID: accountA)
        
        // Account B has NO records
        XCTAssertFalse(termsManager.hasAcceptedCurrentTerms(accountID: accountB))
        XCTAssertEqual(consentManager.decision(for: accountB), .undecided)
        
        // Sign in as Account B
        mockAPI.loginResult = .success(
            AuthResponseDTO(
                accessToken: "token-b",
                tokenType: "bearer",
                user: UserDTO(id: accountB, email: "b@example.com", isActive: true, createdAt: nil)
            )
        )
        
        let successB = await auth.signIn(email: "b@example.com", password: "password123")
        XCTAssertTrue(successB)
        
        // Account B must be stopped at termsRequired! Never inherit Account A!
        XCTAssertEqual(auth.flowState, .termsRequired, "Account B must NOT inherit Account A's accepted Terms!")
        
        // Account B accepts terms
        auth.acceptTermsAndAdvance()
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired, "Account B must NOT inherit Account A's granted Consent!")
        
        // Sign out Account B
        auth.signOut()
        XCTAssertEqual(auth.flowState, .welcome)
        
        // Sign in as Account A
        mockAPI.loginResult = .success(
            AuthResponseDTO(
                accessToken: "token-a",
                tokenType: "bearer",
                user: UserDTO(id: accountA, email: "a@example.com", isActive: true, createdAt: nil)
            )
        )
        
        let successA = await auth.signIn(email: "a@example.com", password: "password123")
        XCTAssertTrue(successA)
        
        // Account A already completed both requirements, so advances straight to ready
        XCTAssertEqual(auth.flowState, .ready, "Account A should proceed straight to ready without prompting again!")
    }
    
    // MARK: - PHASE 25 & 26: App Relaunch Resilience Tests
    
    /// Test 25: Relaunch while Terms is required restores termsRequired state
    func testRelaunchWhileTermsRequired_RestoresTermsRequiredState() async {
        let auth = createAuthManager()
        
        _ = await auth.register(email: "relaunch_terms@example.com", password: "password123")
        XCTAssertEqual(auth.flowState, .termsRequired)
        
        // Simulate app kill and relaunch with stored token & user in UserDefaults
        let relaunchedAuth = createAuthManager()
        XCTAssertEqual(relaunchedAuth.flowState, .termsRequired, "Relaunch must restore termsRequired and not skip to ready!")
    }
    
    /// Test 26: Relaunch while Consent is required restores dataSharingConsentRequired state
    func testRelaunchWhileConsentRequired_RestoresConsentRequiredState() async {
        let auth = createAuthManager()
        
        _ = await auth.register(email: "relaunch_consent@example.com", password: "password123")
        auth.acceptTermsAndAdvance()
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
        
        // Simulate app kill and relaunch
        let relaunchedAuth = createAuthManager()
        XCTAssertEqual(relaunchedAuth.flowState, .dataSharingConsentRequired, "Relaunch must restore dataSharingConsentRequired and not skip to ready!")
    }
    
    // MARK: - Additional Regression Tests
    
    /// Test: Login existing account with incomplete Terms stops at termsRequired
    func testLoginExistingAccount_TermsIncomplete_StopsAtTermsRequired() async {
        let auth = createAuthManager()
        let accountID = "user-incomplete-terms"
        
        // Consent pre-granted, but Terms NOT accepted
        _ = await consentManager.grantConsent(authToken: nil, accountID: accountID)
        
        mockAPI.loginResult = .success(
            AuthResponseDTO(
                accessToken: "token-inc-terms",
                tokenType: "bearer",
                user: UserDTO(id: accountID, email: "incterms@example.com", isActive: true, createdAt: nil)
            )
        )
        
        let success = await auth.signIn(email: "incterms@example.com", password: "password123")
        XCTAssertTrue(success)
        XCTAssertEqual(auth.flowState, .termsRequired)
    }
    
    /// Test: Login existing account with Terms complete but Consent incomplete stops at dataSharingConsentRequired
    func testLoginExistingAccount_ConsentIncomplete_StopsAtConsentRequired() async {
        let auth = createAuthManager()
        let accountID = "user-incomplete-consent"
        
        // Terms pre-accepted, but Consent NOT decided
        termsManager.acceptTerms(accountID: accountID)
        
        mockAPI.loginResult = .success(
            AuthResponseDTO(
                accessToken: "token-inc-consent",
                tokenType: "bearer",
                user: UserDTO(id: accountID, email: "incconsent@example.com", isActive: true, createdAt: nil)
            )
        )
        
        let success = await auth.signIn(email: "incconsent@example.com", password: "password123")
        XCTAssertTrue(success)
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
    }
    
    /// Test: Declining terms signs out the account and returns flowState to welcome
    func testDeclineTerms_SignsOutAndResetsToWelcome() async {
        let auth = createAuthManager()
        
        _ = await auth.register(email: "decliner@example.com", password: "password123")
        XCTAssertEqual(auth.flowState, .termsRequired)
        
        // User declines terms
        auth.signOut()
        XCTAssertEqual(auth.flowState, .welcome)
        XCTAssertNil(auth.currentUser)
        XCTAssertFalse(termsManager.hasAcceptedCurrentTerms(accountID: "decliner@example.com"))
    }
    
    /// Test: Double accept terms is idempotent and does not corrupt state
    func testDoubleAcceptTerms_IsIdempotent() async {
        let auth = createAuthManager()
        
        _ = await auth.register(email: "double_accept@example.com", password: "password123")
        auth.acceptTermsAndAdvance()
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
        
        // Second tap
        auth.acceptTermsAndAdvance()
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)
        XCTAssertTrue(termsManager.hasAcceptedCurrentTerms(accountID: auth.currentUser?.id))
    }
    
    /// Test: Double consent submission is idempotent and maintains ready state
    func testDoubleConsentSubmission_IsIdempotent() async {
        let auth = createAuthManager()
        
        _ = await auth.register(email: "double_consent@example.com", password: "password123")
        auth.acceptTermsAndAdvance()
        
        _ = await auth.recordConsentDecisionAndAdvance(granted: true)
        XCTAssertEqual(auth.flowState, .ready)
        
        // Second tap
        _ = await auth.recordConsentDecisionAndAdvance(granted: true)
        XCTAssertEqual(auth.flowState, .ready)
        XCTAssertEqual(consentManager.decision(for: auth.currentUser?.id), .granted)
    }
}
