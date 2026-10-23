# NeuroPulse AI — Development Rules

**These rules are mandatory instructions for every human contributor and AI coding agent.** If a request conflicts with a safety, privacy, or repository-protection rule, explain the conflict and ask for clarification rather than silently violating the rule.

## 1. General development principles

1. Read `requirements.md`, `architecture.md`, `phases.md`, `tasks.md`, and relevant entries in `memory.md` before starting a task.
2. Work on **one phase at a time**. Do not start future backend, ML, or EEG tasks while the current phase remains incomplete unless explicitly instructed.
3. Inspect the current repository and Git status before editing. Do not assume earlier screenshots perfectly represent the current files.
4. Make the smallest complete change that satisfies the requested task.
5. Explain the plan, files to be changed, and how success will be verified before making a broad or risky change.
6. Never fabricate files, test results, build success, clinical evidence, data, or implemented features.
7. Do not overwrite user changes or discard work to make a task easier.
8. Update `tasks.md` after every meaningful project change. Update `memory.md` with concise, durable decisions and state changes.
9. Keep `requirements.md` and `architecture.md` consistent with actual decisions. Label proposed/future capabilities clearly.
10. Do not claim work has been tested unless the test/build was actually run and the result observed.

## 2. Coding standards

### Swift and SwiftUI

- Use idiomatic, readable Swift and SwiftUI.
- Keep views focused; move nontrivial business logic and calculations into appropriately named types/services.
- Prefer composition and native framework features over custom abstractions that add little value.
- Use access control (`private`, `fileprivate`, `internal`) intentionally.
- Avoid force unwraps and `try!` in production paths. Handle failure explicitly.
- Use Swift concurrency carefully and follow actor/main-thread rules. UI state changes should occur on the appropriate actor.
- Keep long-running calculations and signal processing off the main thread when they could affect responsiveness.
- Keep user-facing strings accessible to VoiceOver and ensure controls have clear labels and sufficient contrast.
- Support dynamic text and common accessibility settings where practical.
- Do not add global mutable state as a shortcut for sharing data.
- Use native SwiftUI `@State`, `@Binding`, and the supported observation approach appropriate to the target iOS version. Don't introduce a state-management package by default.

### Python (future backend/ML only)

- Follow PEP 8 and use type hints for public functions and API schemas.
- Validate untrusted input using Pydantic or equivalent explicit validation.
- Separate route handlers, business logic, data access, feature extraction, and model loading.
- Keep feature calculations deterministic and independently testable.
- Pin/review dependencies for reproducible builds; do not blindly install packages suggested by an AI.

## 3. Libraries/frameworks to prefer

### MVP

- Swift
- SwiftUI
- Swift Charts when charts are implemented
- SwiftData only if the deployment target is iOS 17 or later; otherwise use a compatible persistence option
- AVFoundation only if audio playback is required
- XCTest/Swift Testing and Xcode build tools for verification
- Git and GitHub for source control

### Future phases only

- FastAPI and Pydantic for the Python API
- PostgreSQL with SQLAlchemy and Alembic for server persistence
- NumPy/SciPy for numerical and signal processing
- MNE-Python and a supported headset SDK/BrainFlow when real EEG integration is approved
- XGBoost and scikit-learn for offline model development
- Docker for backend packaging
- React only if a clinician web dashboard is approved

## 4. Libraries and approaches to avoid

- Do not introduce third-party dependencies when SwiftUI or another built-in framework is sufficient.
- Do not add a UI framework, router, database, analytics SDK, or state-management framework without explaining the need.
- Do not add FastAPI, PostgreSQL, Docker, or ML libraries to the iOS target.
- Do not create backend or EEG placeholder implementations in the MVP merely to match a diagram.
- Do not train an ML model on invented clinical labels or present synthetic demo data as real patient data.
- Do not add an unverified EEG SDK or claim headset compatibility before checking hardware and licensing requirements.
- Do not add analytics or advertising SDKs that transmit health-related behavior without an explicit reviewed purpose and consent model.
- Do not create microservices or Kubernetes deployment for the hackathon MVP.

## 5. Error handling

- Validate all captured test data before computing metrics.
- Handle cancelled, interrupted, too-short, empty, and malformed assessments explicitly.
- Guard against zero-duration tests, duplicate/out-of-order timestamps, non-finite numbers, and insufficient samples.
- Use user-friendly error messages that explain the next action; never expose stack traces or internal implementation details to end users.
- Keep error states recoverable where possible (retry, cancel, return home).
- When network services are eventually added, handle timeouts, offline state, authentication expiry, server failures, and safe retries.
- Avoid retry logic that may upload the same contribution more than once; use idempotency where needed.
- Log only what is necessary to debug. Never log tokens, passwords, raw EEG, or unnecessary health data.
- Do not silently convert invalid data to zero or fabricate a successful result.

## 6. Security and privacy

- Never put secrets, API keys, access tokens, private signing keys, passwords, or credentials in source code, `.md` files, screenshots, Git commits, or logs.
- Never commit real patient records, raw EEG, identifiable assessments, or private exports to GitHub.
- Use `.gitignore` for `.DS_Store`, `DerivedData`, user-specific Xcode data, build output, and local secret files. Do not ignore source files or the `.xcodeproj`.
- Keep the repository private unless the team deliberately reviews what can be published.
- The MVP should work without research-data contribution or server accounts.
- Collect only data needed for a defined feature or research question.
- Keep Motor Health, MindEase, and EEG records semantically separate.
- Separate consent for app operation, clinician/report sharing, and research/model-training use.
- Respect consent scope, access control, retention policies, deletion requests, and applicable law before server deployment.
- Pseudonymization is not the same as guaranteed anonymization.
- Store authentication tokens in Keychain on iOS, not ordinary preferences or source files.
- For server deployment, use TLS, secure secret management, least-privilege access, authenticated APIs, resource ownership checks, backups, and documented retention/deletion procedures.
- Do not claim regulatory compliance without a deliberate review of the applicable deployment and intended use.

## 7. Health and AI boundaries — never violate

The AI coding assistant must never:

1. Claim that NeuroPulse AI diagnoses Parkinson's disease, another neurological disease, or a mental-health condition.
2. Treat a decrease in tapping rate, a change in tracing, or an EEG feature as proof of progression, recovery, anxiety, or any other medical conclusion.
3. Invent clinical thresholds, validated scores, patient labels, study results, model accuracy, or medical references.
4. Generate an ML workflow that labels synthetic data as clinical ground truth.
5. Present an XGBoost output as clinically valid without suitable labels, independent evaluation, and review appropriate to its intended use.
6. Describe EEG as mind reading or reliable direct access to thoughts and emotions.
7. Upload motor/EEG data for training without appropriate explicit consent and authorization.
8. Make research-data donation mandatory for basic features.
9. Mix wellness check-ins into motor-function labels without a justified, reviewed research protocol.
10. Give medication-change instructions or imply that app output replaces clinical advice.

Use neutral wording such as “measured change”, “experimental estimate”, “assessment quality”, and “discuss with a healthcare professional” when appropriate.

## 8. Performance expectations

- Touch feedback should feel immediate; avoid network calls in touch handlers.
- Use a monotonic clock for elapsed-time measurements.
- Preserve raw timestamps at sufficient precision for the selected protocol.
- Normalize tracing coordinates against a stable drawing coordinate space.
- Avoid repeatedly recalculating expensive analytics during each SwiftUI redraw.
- Keep scrolling and animations responsive, including on supported older devices.
- Process future EEG signals in bounded chunks or an appropriate background pipeline; avoid unbounded in-memory recordings.
- Provide a graceful low-memory and interrupted-session behavior where practical.
- Test on the simulator and a physical iPhone when available. Simulator touch behavior does not fully substitute for real-device usability testing.

## 9. File organization rules

- Git root is the outer `NeuroPulseAI/` folder.
- `NeuroPulseAI.xcodeproj/` stays at the repository root.
- Swift source code belongs under the inner `NeuroPulseAI/` source tree, never inside the `.xcodeproj` package.
- Put the application entry point in `NeuroPulseAI/App/NeuroPulseAIApp.swift` if the project refactor safely establishes that location.
- Put home navigation under `Features/Home/`.
- Put assessment capture/calculation under `Features/MotorHealth/`.
- Put relaxation flows under `Features/MindEase/`.
- Put cross-session visualizations under `Features/Progress/`.
- Put shared persisted models and storage under `Data/`.
- Put reusable theme/components/utilities under `Core/`.
- Do not scatter unrelated feature code into `ContentView.swift` or one enormous file.
- Do not create duplicate types or duplicate entry points when renaming/moving files.
- Before moving files, inspect the actual Xcode file-reference strategy and make sure every file remains in the app target.
- Avoid direct, unnecessary edits to `project.pbxproj`. Use Xcode-aware file creation/moves where possible and verify the build afterward.
- Do not create empty folders just to match the diagram; add them when a feature needs them.
- Keep documentation files at the repository root unless the team chooses a `docs/` folder consistently. If files are moved, update references.

## 10. Naming conventions

- Swift source files: `UpperCamelCase.swift`, named after their principal type or purpose (`HomeView.swift`, `TappingTestView.swift`, `MotorFeatureCalculator.swift`).
- Swift types, enums, protocols: `UpperCamelCase`.
- Swift properties, functions, and local variables: `lowerCamelCase`.
- Python modules and variables: `snake_case.py` / `snake_case`.
- API routes: plural, resource-oriented nouns; version prefix `/api/v1`.
- Database table and column names: consistent `snake_case`; document units and use foreign keys.
- Git branches: `feature/motor-health`, `fix/spiral-coordinate-bug`, `docs/project-rules`.
- Commits: short imperative descriptions, for example `Add finger tapping capture` or `Document consent flow`.
- Avoid names such as `Final2`, `NewView`, `Temp`, or `Test123` for shipped implementation types.

## 11. Git and multi-device rules

- Never run `git init` in a repository that is already initialized.
- Never replace the established Git remote without a clear reason.
- Pull before beginning work on a device; commit and push working changes before switching devices.
- Never use `git push --force` on `main` as a routine fix.
- Never reset, clean, discard, or rewrite history to remove an issue without explicit user approval and a clear recovery plan.
- Review `git status` and `git diff` before committing.
- Prefer focused commits after verified changes.
- For simultaneous work, use feature branches and reviewed merges/pull requests.
- Do not commit AI-generated changes without inspecting the diff and testing the app.

## 12. AI agent workflow

Before a task:

1. Read this file and relevant project documentation.
2. Inspect the current project structure and Git status.
3. Identify the current phase in `phases.md` and current task in `tasks.md`.
4. State scope and acceptance criteria.
5. Confirm any risky file/project configuration change before performing it.

After a task:

1. Inspect the actual diff.
2. Build/test the app or explicitly state why testing could not be run.
3. Update `tasks.md` after every meaningful change.
4. Record durable decisions/issues in `memory.md`.
5. Do not start another phase until the current phase meets its completion checklist or the user instructs otherwise.
6. Do not push to GitHub unless explicitly asked or the team has explicitly delegated pushes to the agent.
