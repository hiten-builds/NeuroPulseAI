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
- Phase 0, 1, 2, 3, 4, 5, and 6 completed and verified with clean xcodebuild runs (0 errors, 0 warnings).
- Phase 3 implemented: Finger-Tapping protocol with monotonic elapsed time recording (`mach_absolute_time`), `MotorFeatureCalculator` (cadence, intervals, CV, fatigue ratio, quality status gate), and `TappingResultView`.
- Phase 4 implemented: Spiral-Tracing assessment, mathematical Archimedean reference spiral, normalized canvas drag gesture recording, `SpiralFeatureCalculator` (RMSE deviation %, mean deviation, path length ratio, speed CV), and `SpiralResultView`.
- Phase 5 implemented: Local persistence (`MotorSessionRecord`, `MotorSessionStore`), automatic session recording upon test completion, and `ProgressDashboardView` with `Swift Charts` visualizing cadence and RMSE trends.
- Phase 6 implemented: MindEase guided breathing visual pacer (`BreathingSessionView`), mindfulness pause (`MindfulnessMeditationView`), unscored tactile grounding (`MindfulTracingView`), optional relaxation check-ins (`WellnessCheckInView`), and isolated `WellnessSessionStore`.
- All assessment metrics and wellness sessions work offline with on-device persistence and zero network requirements.
- Currently active phase: Ready for Phase 10 (Final release validation and quality review).

## Confirmed product decisions

- Native iOS application: Swift + SwiftUI.
- Main modes: Motor Health and MindEase.
- Motor Health MVP: finger tapping, spiral tracing, transparent movement metrics, and personal trend tracking.
- MindEase MVP: guided breathing, mindfulness/meditation, optional mindful tracing, and optional self-reported relaxation check-ins.
- Initial MVP works locally without requiring a backend, PostgreSQL, trained ML, or EEG hardware.
- Health boundaries: strictly non-diagnostic; clearly labelled demo/sample data; separate wellness storage from motor records.

## Decision log

| Date | Decision | Why |
|---|---|---|
| 2026-10-23 | Use native SwiftUI for the iOS MVP | Native interaction and a straightforward Xcode workflow are suitable for the hackathon. |
| 2026-10-23 | Keep backend, PostgreSQL, XGBoost, and EEG out of the first MVP | Reduces scope and allows the app's core flows to be demonstrated first. |
| 2026-10-23 | Use GitHub as the common synchronization point for multiple Macs | Each device keeps a separate local clone; shared changes move through commit/push/pull. |
| 2026-10-23 | Separate Motor Health data from MindEase wellness data | Prevents relaxation ratings from being interpreted as motor or clinical labels. |
| 2026-10-23 | Leverage Xcode 16 PBXFileSystemSynchronizedRootGroup | Automatically syncs filesystem changes in `NeuroPulseAI/` without risk of `.pbxproj` merge conflicts. |
| 2026-10-23 | Core Design Tokens & Component Library | Established reusable ColorTheme, DesignTokens, ModeCardView, and DisclaimerBanner in Core/ for consistent UX. |
| 2026-10-23 | Monotonic High-Resolution Timing | Used `mach_absolute_time` for finger-tapping and spiral-tracing elapsed intervals to avoid clock skew. |
| 2026-10-23 | Mathematical Archimedean Spiral in Unit Coordinates | Normalized drawing coordinates $[0, 1] \times [0, 1]$ make metrics invariant across iPhone screen sizes. |
| 2026-10-23 | Isolated Sandbox JSON Stores | File-based local persistence works offline, preserves privacy, and eliminates cloud dependency. |

## Current file being worked on

Phases 0 through 6 fully implemented and verified. Next is Phase 10 / QA test cases.

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
