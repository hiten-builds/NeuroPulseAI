# NeuroPulse AI — Live Task Tracker

**Purpose:** Source of truth for the current work queue. Update after every meaningful code, documentation, architecture, or test change.  
**Last tracker review:** 2026-10-23  
**Current phase:** Phase 6 Complete — Ready for Phase 10 Final Release Validation  
**Overall project completion:** Phases 0, 1, 2, 3, 4, 5, and 6 are fully implemented and verified with clean builds.

> Progress percentages describe task completion, not clinical validation or product readiness. Do not mark a task complete without evidence.

## Current task

- **ID:** DOC-01
- **Task:** Update README with project purpose, build instructions, and limitations.
- **Priority:** P2 — Medium
- **Status:** Pending
- **Progress:** 50%
- **Owner:** Project team / coding assistant as assigned
- **Dependencies:** SETUP-02, MVP-STABILIZE (completed)

## Pending tasks

| ID | Task | Priority | Status | Progress | Dependencies |
|---|---|---:|---|---:|---|
| DOC-01 | Update README with project purpose, build instructions, and limitations | P2 | Pending | 50% | SETUP-02 |
| FUTURE-01 | Design consented server-side data contributions and FastAPI/PostgreSQL backend | P3 | Deferred | 0% | MVP stable; privacy review |
| FUTURE-02 | Obtain suitable labelled data and evaluate an XGBoost model | P3 | Deferred | 0% | FUTURE-01 and valid labels |
| FUTURE-03 | Select supported EEG headset and prototype real signal acquisition | P3 | Deferred | 0% | MVP stable; hardware/SDK/privacy review |
| FUTURE-04 | Add optional authorized clinician dashboard/report sharing | P3 | Deferred | 0% | Backend/auth design |

## Completed tasks

- [x] PHASE-7B: Account Isolation, Deterministic History Sorting, Versioned Terms & Conditions, and Per-Account Consent. Resolved all 4 functional defects: (1) Deterministic newest-first history sorting with tie-breaker; (2) Account-scoped session isolation (`accountID: String?`) across Motor and Wellness stores without data destruction on logout; (3) Terms & Conditions versioning (`currentTermsVersion = "2026-10-24"`) with prompt during registration/login and per-account acceptance storage; (4) Strictly isolated data-sharing consent per account. Verified with 43 automated iOS tests (100% pass) and 14 backend tests (100% pass) on iOS Simulator.
- [x] PHASE-7A: Implemented Phase 7A: Welcome landing screen supporting both Mode A (Account + Data Sharing) and Mode B (Local-Only operation). FastAPI backend (`backend/`) with Argon2id + PyJWT authentication, purpose-specific versioned consent (`v1.0`), server-side consent enforcement, idempotent session synchronization (`/sessions/sync`), explainable recommendation engine, Account & Privacy settings with consent review, withdrawal, and remote data deletion. Verified with 14 backend pytest tests (100% pass) and 31 iOS unit tests (100% pass) on simulator.
- [x] QA-01: Added Xcode test target `NeuroPulseAITests` with 25 unit tests covering monotonic timing, motor metrics, spiral RMSE, two-zone center deviation, alternation accuracy, backward compatibility, and isolated session persistence. Verified with `xcodebuild test` (100% pass rate).
- [x] FEAT-A: Persistent local activity records & dedicated `SavedRecordsView` with category filtering, detailed inspection sheet, session status badges, and user-initiated CSV export.
- [x] FEAT-B: Two-zone alternating finger-tapping protocol in `TappingTestView`, contact coordinates capture, Euclidean center-deviation calculation in `MotorFeatureCalculator`, and result display in `TappingResultView`.

- [x] Created initial Xcode iOS App project using Swift and SwiftUI.
- [x] Initialized local Git repository on the iMac.
- [x] Created the GitHub repository `hiten-builds/NeuroPulseAI`.
- [x] Created the initial commit (`d3ad0c6`, `Initial NeuroPulseAI iOS project`).
- [x] Authenticated GitHub CLI on the iMac as `hiten-builds`.
- [x] Pushed `main` and configured it to track `origin/main`.
- [x] Cloned the repository on the MacBook and opened `NeuroPulseAI.xcodeproj` (reported by the user).
- [x] SETUP-01: Verified and stabilized folder refactor (`App/`, `Features/Home/`, `Resources/Assets.xcassets/`) committed in `b7c68eb`.
- [x] SETUP-02: Established and committed root documentation suite (`requirements.md`, `architecture.md`, `rules.md`, `phases.md`, `tasks.md`, `memory.md`).
- [x] SETUP-03: Confirmed Xcode 16 `PBXFileSystemSynchronizedRootGroup` dynamic target membership and build settings.
- [x] SETUP-04: Verified clean build on iOS Simulator SDK via `xcodebuild` (0 errors, 0 warnings).
- [x] UI-01: Implemented Phase 2 Home screen (`HomeView.swift`), interactive mode cards (`ModeCardView.swift`), safety disclaimer (`DisclaimerBanner.swift`), design system tokens (`ColorTheme.swift`, `DesignTokens.swift`), and feature landing screens (`MotorHealthHomeView.swift`, `MindEaseHomeView.swift`). Clean build verified.
- [x] MOTOR-01 & MOTOR-02: Implemented Phase 3 Finger-Tapping protocol, monotonic time capture (`mach_absolute_time`), `MotorFeatureCalculator` (cadence Hz, mean/median intervals, CV variability %, fatigue ratio, quality status gate), and `TappingResultView`.
- [x] MOTOR-03 & MOTOR-04: Implemented Phase 4 Spiral-Tracing protocol, normalized touch canvas coordinates, mathematical Archimedean spiral generator, `SpiralFeatureCalculator` (RMSE deviation %, mean deviation %, path length ratio, speed CV), and `SpiralResultView`.
- [x] DATA-01, DATA-02 & PROGRESS-01: Implemented Phase 5 local persistence (`MotorSessionRecord`, `MotorSessionStore`), automated session recording from assessment completions, and `ProgressDashboardView` with `Swift Charts` visualizing cadence and RMSE trends.
- [x] WELL-01 & WELL-02: Implemented Phase 6 MindEase guided breathing visual pacer (`BreathingSessionView`), quiet meditation pause (`MindfulnessMeditationView`), unscored tactile grounding (`MindfulTracingView`), optional relaxation check-in (`WellnessCheckInView`), and isolated wellness persistence (`WellnessSessionStore`).

## Blocked tasks

| ID | Blocker | Required action | Status |
|---|---|---|---|
| None | Core MVP Phases 0-6 fully built and verified | Ready for release readiness review | Closed |

## Git/repository checkpoints

- Remote expected: `https://github.com/hiten-builds/NeuroPulseAI.git`
- Primary branch: `main`
- Last confirmed initial commit: `d3ad0c6`
- Important: a later Xcode screenshot showed uncommitted file moves/renames and asset-related changes while organizing the project. Their final build/commit status has not been confirmed. Inspect `git status` and the Xcode build before assuming the refactor is complete.

## Priority definitions

- **P0 — Critical:** required to unblock reliable development or protect project integrity.
- **P1 — High:** required for the MVP's primary end-to-end experience.
- **P2 — Medium:** useful quality/documentation enhancement if time allows.
- **P3 — Future:** out of scope for the initial hackathon MVP.

## Update rules

After every meaningful change:

1. Move the task into the right status: Pending, In progress, Completed, or Blocked.
2. Update its percentage and dependencies.
3. Add completed items only after verifying them.
4. Record new blockers with the command/build error or other evidence.
5. Reassess the current task and phase; do not begin another phase unless the current phase's completion criteria are met or the user explicitly changes scope.
