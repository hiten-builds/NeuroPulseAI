# NeuroPulse AI — Live Task Tracker

**Purpose:** Source of truth for the current work queue. Update after every meaningful code, documentation, architecture, or test change.  
**Last tracker review:** 2026-10-23  
**Current phase:** Phase 2 — Home screen and navigation  
**Overall project completion:** Phase 0 & Phase 1 baseline established; entering Phase 2.

> Progress percentages describe task completion, not clinical validation or product readiness. Do not mark a task complete without evidence.

## Current task

- **ID:** UI-01
- **Task:** Implement home screen and navigation to Motor Health and MindEase.
- **Priority:** P0 — Critical
- **Status:** Pending
- **Progress:** 0%
- **Owner:** Project team / coding assistant as assigned
- **Dependencies:** Phase 0 and Phase 1 completion (satisfied)
- **Acceptance criteria:** Both mode cards are visible, responsive, and navigate cleanly; non-diagnostic disclaimer is displayed; layout works across iPhone simulator screen sizes; clean build succeeds.

## Pending tasks

| ID | Task | Priority | Status | Progress | Dependencies |
|---|---|---:|---|---:|---|
| UI-01 | Implement home screen and navigation to Motor Health and MindEase | P0 | Pending | 0% | Phase 1 foundation |
| MOTOR-01 | Implement finger-tapping capture with monotonic timestamps | P1 | Pending | 0% | UI-01 |
| MOTOR-02 | Implement tapping metrics, input validation, and quality status | P1 | Pending | 0% | MOTOR-01 |
| MOTOR-03 | Implement spiral tracing and normalized path capture | P1 | Pending | 0% | UI-01 |
| MOTOR-04 | Implement tracing metrics and invalid-trace handling | P1 | Pending | 0% | MOTOR-03 |
| DATA-01 | Define local MotorSession and WellnessSession models | P1 | Pending | 0% | Model scope agreed |
| DATA-02 | Add persistence and session history after selecting deployment-target-compatible storage | P1 | Pending | 0% | MOTOR-02, MOTOR-04, DATA-01 |
| PROGRESS-01 | Build results and historical charts; label demo data clearly | P1 | Pending | 0% | DATA-02 |
| WELL-01 | Implement MindEase guided breathing experience | P1 | Pending | 0% | UI-01 |
| WELL-02 | Add optional relaxation check-ins and separate wellness history | P2 | Pending | 0% | WELL-01, DATA-01 |
| QA-01 | Add test cases for motor calculations and quality rules | P1 | Pending | 0% | MOTOR-02, MOTOR-04 |
| DOC-01 | Update README with project purpose, build instructions, and limitations | P2 | Pending | 0% | SETUP-02 |
| FUTURE-01 | Design consented server-side data contributions and FastAPI/PostgreSQL backend | P3 | Deferred | 0% | MVP stable; privacy review |
| FUTURE-02 | Obtain suitable labelled data and evaluate an XGBoost model | P3 | Deferred | 0% | FUTURE-01 and valid labels |
| FUTURE-03 | Select supported EEG headset and prototype real signal acquisition | P3 | Deferred | 0% | MVP stable; hardware/SDK/privacy review |
| FUTURE-04 | Add optional authorized clinician dashboard/report sharing | P3 | Deferred | 0% | Backend/auth design |

## Completed tasks

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

## Blocked tasks

| ID | Blocker | Required action | Status |
|---|---|---|---|
| None | No blockers identified | Proceed with Phase 2 implementation | Closed |

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
