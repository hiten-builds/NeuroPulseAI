# NeuroPulse AI — Development Phases

**Execution rule:** Work on one phase at a time unless the user explicitly authorizes otherwise. Complete the checklist and update `tasks.md`/`memory.md` before advancing.

## Phase 0 — Repository and Xcode baseline

### Objective
Confirm the existing Xcode project, local repository, GitHub remote, build scheme, and current working tree before changing code.

### Features/tasks
- Inspect `.gitignore`, README, Xcode project settings, file references, target membership, scheme, deployment target, Git status, and remote.
- Confirm the current starter app builds and launches in an available simulator.
- Resolve any in-progress file moves/renames carefully.
- Confirm the six project documents are in the agreed location.

### Deliverables
- Known-good baseline build or a clear list of pre-existing errors.
- Verified folder/file map.
- Clean and documented Git state.

### Dependencies
- Existing Xcode project and access to the Git repository.

### Completion checklist
- [ ] Correct `.xcodeproj` and app target identified.
- [ ] All current source files resolve and target membership is correct.
- [ ] App builds and launches, or unresolved baseline blockers are documented.
- [ ] Git root and `origin` are correct.
- [ ] `tasks.md` and `memory.md` reflect the observed state.

## Phase 1 — Folder structure and app foundation

### Objective
Create a maintainable feature-oriented structure without breaking the Xcode project.

### Features/tasks
- Organize app entry point, Home, Core, Features, Data, and Resources as needed.
- Safely rename `ContentView` to `HomeView` only if the app entry point and references are updated together.
- Establish minimal reusable styling and navigation.
- Keep folder creation incremental; do not create empty placeholder Swift files.

### Deliverables
- Agreed folder structure.
- One unambiguous app entry point and home screen.
- Successful Xcode build.

### Dependencies
- Phase 0 complete.

### Completion checklist
- [ ] `.xcodeproj` remains at repository root.
- [ ] No duplicate `@main` declarations or duplicate home views.
- [ ] New files are included in the correct target.
- [ ] App builds and runs.
- [ ] Changes reviewed and documented.

## Phase 2 — Home screen and navigation

### Objective
Implement a clear, polished home screen that exposes Motor Health and MindEase.

### Features/tasks
- Build `HomeView` with the NeuroPulse AI identity and two main mode cards.
- Navigate to a Motor Health landing screen and MindEase landing screen.
- Define reusable colors, spacing, typography, card styles, and button styles where useful.
- Add accessibility labels and readable contrast.
- Avoid premature backend/auth flows.

### Deliverables
- Functional home dashboard and navigation.
- Consistent reusable UI building blocks.

### Dependencies
- Phase 1 complete.

### Completion checklist
- [ ] Both mode cards are visible and navigate correctly.
- [ ] Layout works in the intended iPhone simulator sizes.
- [ ] Accessibility and empty states are reviewed.
- [ ] App builds and runs.
- [ ] Commit/checkpoint is prepared.

## Phase 3 — Motor Health: finger-tapping assessment

### Objective
Build the first real motor test with reproducible touch capture and transparent metrics.

### Features/tasks
- Show instructions and optional practice.
- Implement a documented, configurable duration (15 seconds may be used for prototype testing).
- Capture touch timestamps with a monotonic clock and target identity.
- Handle countdown, running, complete, cancelled, interrupted, and invalid states.
- Implement pure metric calculation and quality validation.
- Add tests or deterministic examples for known event sequences.

### Deliverables
- Functional finger-tapping flow.
- Structured result model.
- Documented metric names, units, and limitations.

### Dependencies
- Phase 2 complete.

### Completion checklist
- [ ] Real touch events are captured.
- [ ] Timing uses an appropriate monotonic clock.
- [ ] Invalid/too-short attempts are flagged safely.
- [ ] Metric calculations handle insufficient samples and zero/invalid intervals.
- [ ] No diagnostic claims are shown.
- [ ] App builds and the flow is tested.

## Phase 4 — Motor Health: spiral tracing

### Objective
Implement an unambiguous tracing protocol and calculate geometric/time features.

### Features/tasks
- Draw the reference spiral in a stable coordinate space.
- Capture touch path points and timestamps.
- Normalize coordinates relative to the drawing area.
- Calculate path length, duration, and reference-path deviation.
- Handle cancellation, invalid traces, and insufficient points.
- Show the original trace over the reference path when useful.

### Deliverables
- Working tracing assessment.
- Documented calculation and quality rules.

### Dependencies
- Phase 3 complete, so test result handling can be reused safely.

### Completion checklist
- [ ] Tracing works on an iPhone Simulator and, where possible, a physical device.
- [ ] Path measurements have known units and documented definitions.
- [ ] Coordinate/resizing behavior is checked.
- [ ] Invalid traces do not produce misleading metrics.
- [ ] App builds and the flow is tested.

## Phase 5 — Results, history, and local persistence

### Objective
Make the assessment useful beyond a single demo attempt.

### Features/tasks
- Build a clear results screen for each test.
- Add history and comparison charts using Swift Charts.
- Add an empty state for users with no history.
- Add local persistence using SwiftData if iOS 17+ is the target; verify the actual deployment setting first.
- Keep sample/demo history visibly labelled.
- Optionally add user-initiated report export after review.

### Deliverables
- Saved local motor sessions.
- Historical trend chart and explanatory text.
- Results flow that separates measurement from clinical interpretation.

### Dependencies
- Phases 3 and 4 complete.

### Completion checklist
- [ ] Sessions persist and reload correctly.
- [ ] Empty, single-session, and multi-session states work.
- [ ] Comparable protocols are identified before comparisons.
- [ ] Demo data cannot be mistaken for real health data.
- [ ] App builds and tests pass.

## Phase 6 — MindEase wellness features

### Objective
Build a complete but separate guided wellness experience.

### Features/tasks
- Add an animated guided breathing exercise with start, stop, and completion states.
- Add a short mindfulness/meditation experience; audio is optional.
- Optionally add mindful tracing as an unscored wellness exercise.
- Add optional before/after relaxation check-ins.
- Store wellness sessions separately from motor assessments.
- Add a history/preferences view if time permits.

### Deliverables
- Working MindEase flow.
- Wellness session model and clear distinction from clinical data.

### Dependencies
- Phase 2 complete; local persistence may be reused after Phase 5 where appropriate.

### Completion checklist
- [ ] Breathing animation works and can be stopped at any time.
- [ ] No mandatory breath-holding or uncomfortable breathing instructions.
- [ ] Check-ins are optional and skippable.
- [ ] Wellness ratings are not treated as motor or diagnostic labels.
- [ ] App builds and flows are tested.

## Phase 7A — Account Authentication, Optional Data Consent, and Personalized Recommendations (COMPLETED)

### Objective
Add a secure multi-user backend foundation, two equally supported operating modes (Local-Only vs Consented), purpose-specific versioned consent, idempotent session synchronization, and explainable recommendations while strictly preserving local storage and MVP assessment features.

### Features/tasks
- Implement Welcome landing screen supporting both "Sign In / Register" and prominent "Continue Locally".
- Implement secure email/password authentication using Argon2id password hashing and PyJWT tokens on FastAPI backend (`backend/`).
- Secure iOS Keychain storage (`KeychainHelper.swift`) for tokens and sensitive session data.
- Implement purpose-specific versioned data consent (`v1.0`) for personalized recommendations.
- Keep account creation and data-sharing permission strictly separate.
- Implement server-side consent enforcement: reject session uploads with 403 Forbidden if consent is absent, declined, or withdrawn.
- Implement idempotent sync service (`SyncService.swift` and `/sessions/sync`) tracking local IDs so duplicate uploads are avoided.
- Implement explainable recommendations: data-driven insights with evidence metrics for consented accounts, deterministic on-device baseline guidance for local-only users.
- Add Account & Privacy settings screen with consent review, consent withdrawal, and remote data deletion (`DELETE /account/data`).
- Comprehensive automated tests: 14 backend pytest tests + 6 new iOS unit tests (31/31 passed).

### Completion checklist
- [x] Auth and ownership checks are tested.
- [x] Consent is separate from basic app access and account creation.
- [x] Declining consent does not disable or reduce motor assessment or wellness features.
- [x] No raw health data or secrets are logged or committed.
- [x] Idempotent session synchronization implemented and verified.
- [x] Consent withdrawal and remote-data deletion workflow implemented and verified.
- [x] Backend startup, migrations, and health check verified.


## Phase 8 — XGBoost model pipeline (future)

### Objective
Evaluate whether defined motor/EEG features can estimate a specific, appropriate labelled outcome.

### Features/tasks
- Define the target and its trustworthy source before training.
- Curate appropriately consented, quality-controlled, labelled data.
- Implement versioned preprocessing and feature pipelines.
- Split by participant, not randomly by rows from the same participants.
- Train candidate XGBoost regression/classification models where appropriate.
- Evaluate performance, calibration/uncertainty, generalization and limitations.
- Create model approval, versioning, and rollback procedures.
- Serve only approved models from a protected API.

### Deliverables
- Reproducible research pipeline and evaluation report.
- Model card/limitations and versioned artifact if evidence supports deployment.

### Dependencies
- Phase 7 data pipeline or another properly governed labelled dataset.

### Completion checklist
- [ ] Target and labels are justified and documented.
- [ ] Training/test participants are separated.
- [ ] No synthetic labels are represented as clinical truth.
- [ ] Independent evaluation and limitations are documented.
- [ ] The model output is not described as diagnosis.
- [ ] Deployment reviewed for the intended use.

## Phase 9 — EEG / NeuroSignals (optional future)

### Objective
Explore real EEG capture from one compatible headset under a defined protocol.

### Features/tasks
- Select hardware after checking iOS SDK support, device compatibility, licensing, and data-export rights.
- Add explicit consent and a recording-status/signal-quality UI.
- Implement acquisition and signal-quality checks.
- Define filtering, artifact handling, segmentation, feature extraction, and recording retention.
- Keep EEG records separate from motor/wellness data.
- Only use EEG in ML research with appropriate labels, permissions, and validation.

### Deliverables
- Verified headset connection and recorded signal trace, or a documented hardware blocker.
- Reproducible processing protocol.

### Dependencies
- MVP is stable, approved hardware is available, and the privacy/research plan is clear.

### Completion checklist
- [ ] Actual supported headset/SDK has been verified.
- [ ] No simulated waveform is represented as a real recording.
- [ ] Poor signal quality is detected and explained.
- [ ] Consent and storage policy are implemented.
- [ ] No thought-reading or diagnostic claims are made.

## Phase 10 — Final validation and release readiness

### Objective
Prepare a credible demo and review whether any future real-world deployment needs additional clinical, security, legal, or regulatory work.

### Features/tasks
- Run clean builds and a test checklist on supported simulator/device configurations.
- Check VoiceOver, dynamic type, contrast, navigation, errors, and session interruptions.
- Review privacy notices and data deletion/export behavior.
- Verify GitHub repository contains no secrets, private recordings, or accidental generated artifacts.
- Prepare demo script, screenshots, architecture diagrams, and known-limitations section.

### Deliverables
- Demo-ready MVP and documented limitations.
- Final test and issue summary.

### Dependencies
- MVP phases completed; later phases only if included in the release scope.

### Completion checklist
- [ ] Critical test paths pass.
- [ ] Known bugs and unsupported features are disclosed.
- [ ] No unvalidated medical claims appear in the app or presentation.
- [ ] Git status and release commit are reviewed.
