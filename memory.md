# NeuroPulse AI — Working Memory

This file is intentionally kept lightweight. Record durable decisions, verified implementation changes, current state, and context needed by a future AI session. Do not copy large logs or speculative plans here; use the other project documents for requirements and architecture.

## Current status

- Product: NeuroPulse AI, a native iOS app built with Swift and SwiftUI.
- Repository: `https://github.com/hiten-builds/NeuroPulseAI.git`.
- Main branch: `main`.
- Base refactor committed: `b7c68eb` — `created structure` (`App/`, `Features/Home/`, `Resources/Assets.xcassets/`).
- App builds and verifies cleanly with Xcode 16 / `xcodebuild` targeting iOS Simulator SDK.
- Project reference strategy confirmed: Xcode 16 `PBXFileSystemSynchronizedRootGroup` dynamically synchronizes `NeuroPulseAI/` directory.
- Root documentation suite (`requirements.md`, `architecture.md`, `rules.md`, `phases.md`, `tasks.md`, `memory.md`) committed to repository.
- Phase 0, 1, and 2 completed.
- Phase 2 implemented: `HomeView.swift` dashboard with `ModeCardView` navigation, non-diagnostic `DisclaimerBanner.swift`, design tokens (`ColorTheme.swift`, `DesignTokens.swift`), and feature landing shells (`MotorHealthHomeView.swift`, `MindEaseHomeView.swift`).
- Clean build verified on iOS Simulator SDK with 0 errors / 0 warnings.
- Currently active phase: Phase 3 (Motor Health: finger-tapping assessment).

## Confirmed product decisions

- Native iOS application: Swift + SwiftUI.
- Main modes: Motor Health and MindEase.
- Motor Health MVP: finger tapping, spiral tracing, transparent movement metrics, and personal trend tracking.
- MindEase MVP: guided breathing, mindfulness/meditation, optional mindful tracing, and optional self-reported relaxation check-ins.
- Initial MVP should work locally without requiring a backend, PostgreSQL, trained ML, or EEG hardware.
- Future direction: FastAPI + PostgreSQL, separate consent-based research contribution workflow, server-hosted XGBoost model, optional EEG headset integration, and potentially a clinician-facing dashboard.
- Health boundaries: do not claim diagnosis or clinical validation; label demo/synthetic data clearly; keep wellness records distinct from motor measurements.
- Development uses AI coding tools heavily, but generated changes must be inspected, built/tested, and tracked in Git.

## Decision log

| Date | Decision | Why |
|---|---|---|
| 2026-10-23 | Use native SwiftUI for the iOS MVP | Native interaction and a straightforward Xcode workflow are suitable for the hackathon. |
| 2026-10-23 | Keep backend, PostgreSQL, XGBoost, and EEG out of the first MVP | Reduces scope and allows the app's core flows to be demonstrated first. |
| 2026-10-23 | Use GitHub as the common synchronization point for multiple Macs | Each device keeps a separate local clone; shared changes move through commit/push/pull. |
| 2026-10-23 | Separate Motor Health data from MindEase wellness data | Prevents relaxation ratings from being interpreted as motor or clinical labels. |
| 2026-10-23 | Leverage Xcode 16 PBXFileSystemSynchronizedRootGroup | Automatically syncs filesystem changes in `NeuroPulseAI/` without risk of `.pbxproj` merge conflicts. |
| 2026-10-23 | Core Design Tokens & Component Library | Established reusable ColorTheme, DesignTokens, ModeCardView, and DisclaimerBanner in Core/ for consistent UX. |

## Current file being worked on

Phase 2 completed. Next is Phase 3: `Features/MotorHealth/` (tapping recorder and protocol views).

## Known issues / verification needed

- Verify deployment-target-compatible persistence API (SwiftData vs SQLite/file-based) when entering Phase 5 (deployment target is 27.0 in project settings).
- Do not assume a real EEG headset, SDK, labelled dataset, server environment, or deployed ML model is available.

## Future improvements

Use `tasks.md` and `phases.md` as the task/roadmap source of truth. Add a memory entry only when a decision, implementation change, issue, or workflow detail is likely to matter in a later session.

## Session update template

Append or revise concise bullets when needed:

- **Date:** YYYY-MM-DD
- **Completed:** Verified changes only.
- **Decision and rationale:** Durable choices and why they were made.
- **Current implementation status:** What actually builds/runs.
- **Files touched:** Important paths only.
- **Known issues/blockers:** Include useful reproducible evidence.
- **Next step:** One concrete task from `tasks.md`.
