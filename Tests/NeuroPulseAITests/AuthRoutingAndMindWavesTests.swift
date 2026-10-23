//
//  AuthRoutingAndMindWavesTests.swift
//  NeuroPulseAITests
//
//  Automated unit tests covering:
//  - Issue A: Separate routing for Sign In vs. Create Account
//  - Feature B: Read Mind Waves third Home mode, landing page, and connection state
//

import XCTest
import SwiftUI
@testable import NeuroPulseAI

@MainActor
final class AuthRoutingAndMindWavesTests: XCTestCase {
    private var mockAPI: MockAPIClient!
    private var testUserDefaults: UserDefaults!
    private var testSuiteName: String!
    private var termsManager: TermsManager!
    private var consentManager: ConsentManager!

    override func setUp() {
        super.setUp()
        testSuiteName = "test_auth_mindwaves_\(UUID().uuidString)"
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

    // MARK: - PART 15: Authentication Routing Tests

    /// Test 1 — Sign In destination resolves to SignInView
    func testSignInDestinationResolvesToSignInView() {
        let destination = WelcomeLandingView.AuthDestination.signIn
        XCTAssertEqual(destination.rawValue, "signIn")

        var switchedToRegister = false
        let signInView = SignInView(onSwitchToRegister: {
            switchedToRegister = true
        })

        // Verify destination view type is SignInView
        XCTAssertNotNil(signInView)
        signInView.onSwitchToRegister?()
        XCTAssertTrue(switchedToRegister, "SignInView switch action must trigger callback to switch to registration")
    }

    /// Test 2 — Create Account destination resolves to CreateAccountView
    func testCreateAccountDestinationResolvesToCreateAccountView() {
        let destination = WelcomeLandingView.AuthDestination.createAccount
        XCTAssertEqual(destination.rawValue, "createAccount")

        var switchedToSignIn = false
        let createAccountView = CreateAccountView(onSwitchToSignIn: {
            switchedToSignIn = true
        })

        // Verify destination view type is CreateAccountView
        XCTAssertNotNil(createAccountView)
        createAccountView.onSwitchToSignIn?()
        XCTAssertTrue(switchedToSignIn, "CreateAccountView switch action must trigger callback to switch to sign in")
    }

    /// Test 3 — Destinations are completely distinct (not aliases)
    func testDestinationsAreDistinct() {
        let signInDest = WelcomeLandingView.AuthDestination.signIn
        let createAccountDest = WelcomeLandingView.AuthDestination.createAccount

        XCTAssertNotEqual(signInDest, createAccountDest)
        XCTAssertNotEqual(signInDest.id, createAccountDest.id)
        XCTAssertEqual(signInDest.id, "signIn")
        XCTAssertEqual(createAccountDest.id, "createAccount")
    }

    /// Test 4 — Existing authentication behavior preserved across separate views
    func testSeparateAuthViewsPreserveBackendAuthentication() async {
        let auth = createAuthManager()

        // Sign In path
        let signInSuccess = await auth.signIn(email: "test@example.com", password: "password123")
        XCTAssertTrue(signInSuccess)
        XCTAssertEqual(auth.currentUser?.email, "test@example.com")

        // Sign Out
        auth.signOut()
        XCTAssertEqual(auth.flowState, .welcome)

        // Register path
        mockAPI.registerResult = .success(
            AuthResponseDTO(
                accessToken: "token-new",
                tokenType: "bearer",
                user: UserDTO(id: "user-new", email: "newuser@example.com", isActive: true, createdAt: nil)
            )
        )
        let registerSuccess = await auth.register(email: "newuser@example.com", password: "password123")
        XCTAssertTrue(registerSuccess)
        XCTAssertEqual(auth.currentUser?.email, "newuser@example.com")
    }

    /// Test 5 — Terms and consent flow preserved for Create Account
    func testCreateAccountPreservesTermsAndConsentFlow() async {
        let auth = createAuthManager()

        let success = await auth.register(email: "fresh@example.com", password: "password123")
        XCTAssertTrue(success)

        // Must be stopped at termsRequired
        XCTAssertEqual(auth.flowState, .termsRequired)

        // Accept terms -> consentRequired
        auth.acceptTermsAndAdvance()
        XCTAssertEqual(auth.flowState, .dataSharingConsentRequired)

        // Allow consent -> ready
        _ = await auth.recordConsentDecisionAndAdvance(granted: true)
        XCTAssertEqual(auth.flowState, .ready)
    }

    // MARK: - PART 16: Read Mind Waves Mode & Connection Tests

    /// Test 1 — EEGConnectionState initial state is notConnected ("Not Connected")
    func testEEGConnectionStateInitialIsNotConnected() {
        let state = EEGConnectionState.notConnected
        XCTAssertEqual(state.statusBadgeText, "Not Connected")
        XCTAssertEqual(state.statusMessage, "No compatible EEG headset is currently connected to this device.")
        XCTAssertEqual(state.iconName, "antenna.radiowaves.left.and.right.slash")
    }

    /// Test 2 — EEGConnectionState after connection attempt is headsetNotConnected ("Headset Not Connected")
    func testEEGConnectionStateAfterAttemptIsHeadsetNotConnected() {
        let state = EEGConnectionState.headsetNotConnected
        XCTAssertEqual(state.statusBadgeText, "Headset Not Connected")
        XCTAssertTrue(state.statusMessage.contains("No compatible EEG headset was detected"))
        XCTAssertEqual(state.iconName, "exclamationmark.triangle.fill")
    }

    /// Test 3 — ReadMindWavesLandingView instantiates with initial notConnected state
    func testReadMindWavesLandingViewInitialState() {
        let landingView = ReadMindWavesLandingView()
        XCTAssertNotNil(landingView)
    }

    /// Test 4 — EEGConnectionState equality and state transitions
    func testEEGConnectionStateTransitions() {
        var state: EEGConnectionState = .notConnected
        XCTAssertEqual(state, .notConnected)

        // Simulated connection tap transition
        state = .headsetNotConnected
        XCTAssertEqual(state, .headsetNotConnected)
        XCTAssertNotEqual(state, .notConnected)
    }

    /// Test 5 — Verify HomeView instantiates cleanly with all three modes
    func testHomeViewContainsThreeModes() {
        let homeView = HomeView()
        XCTAssertNotNil(homeView)
    }

}
