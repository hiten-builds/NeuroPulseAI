# NeuroPulse AI — Project Requirements

**Document status:** Initial requirements baseline  
**Product status:** Early iOS prototype / hackathon MVP  
**Last context update:** 2026-10-23

## 1. Product summary

NeuroPulse AI is a native iOS application intended to combine two complementary experiences:

1. **Motor Health:** Smartphone-based fine-motor tasks, initially finger tapping and spiral tracing, that calculate movement measurements and help a user compare valid sessions over time.
2. **MindEase:** A separate wellness area for guided breathing, mindfulness/meditation, mindful tracing, and optional self-reported relaxation check-ins.

Future versions may support optional EEG headset recording, consent-based data contributions, a hosted XGBoost model, and clinician-authorized report sharing. These future capabilities are not required for the first hackathon MVP.

NeuroPulse AI is not a diagnostic system. The first version must not tell users they have a neurological or mental-health condition, infer a medical diagnosis from movement or EEG, or suggest changes to treatment.

## 2. Project goals

- Build a functional, polished native iOS prototype in Swift and SwiftUI.
- Make the two main areas—Motor Health and MindEase—easy to discover and use.
- Capture genuine touch-interaction data for motor assessments rather than relying solely on hardcoded demo values.
- Calculate transparent, explainable motor measurements on-device.
- Allow users to see session summaries and, when history is available, compare their own measurements across sessions.
- Provide simple guided wellness exercises that work without a backend.
- Keep assessment data separate from wellness-session data.
- Maintain a predictable file structure and a GitHub workflow that supports development on multiple Macs and AI coding tools.
- Keep the initial system small enough to build and demonstrate during a hackathon.
- Define a safe path toward future research features without representing them as already implemented or clinically validated.

## 3. Target users

### Primary prototype users

- People who want to record and understand changes in fine-motor task performance.
- People already receiving care for movement-related conditions who may use the measurements as supplementary information, subject to appropriate clinician guidance.

### Secondary users

- Clinicians or rehabilitation professionals who may review a user-authorized report in a future version.
- Caregivers helping a user complete assessments, if access is explicitly authorized in a future version.
- General users who want guided breathing and mindfulness activities through MindEase.
- Researchers, in a future approved research workflow, who may use appropriately consented and labelled data.

The MVP does not require clinician accounts, caregiver accounts, patient onboarding to a hospital, or integration with medical records.

## 4. Core MVP requirements

### 4.1 App foundation and navigation

- Create a native iOS app named `NeuroPulseAI` using Swift and SwiftUI.
- Provide a home screen with clear entry points to **Motor Health** and **MindEase**.
- Use reusable components and a consistent visual design system.
- Include sensible loading, empty, error, accessibility, and navigation states where applicable.
- Preserve the existing Xcode project configuration and app entry point unless a change is required and verified.

### 4.2 Motor Health — finger-tapping assessment

- Show instructions and an optional short practice step before recording.
- Provide a defined, repeatable timed protocol. A 15-second duration may be used for the prototype, but it must be configurable in one place and documented as a prototype choice rather than a clinical standard.
- Capture actual tap events with elapsed timestamps and relevant target information.
- Use a monotonic clock for elapsed-time measurement.
- Detect clearly invalid or incomplete attempts, such as too few events or interrupted recording.
- Calculate and present explainable measurements, including:
  - accepted tap count and tapping rate;
  - inter-tap intervals and median interval;
  - timing variability when enough valid observations exist;
  - target accuracy if the protocol includes alternating targets;
  - data-quality status.
- Label each attempt with protocol version, tested hand when applicable, and duration.
- Do not present measurements as a diagnosis or validated clinical score.

### 4.3 Motor Health — spiral-tracing assessment

- Display a defined reference path and let the user trace using touch input.
- Record timestamped, normalized points within the drawing area.
- Calculate transparent measurements such as completion time, path length, and deviation from the reference path.
- Apply appropriate validation and smoothing before calculating noisy derivative-based features.
- Handle cancellation, incomplete traces, coordinate changes, and invalid attempts.
- Display the reference path and actual trace together when useful.
- Do not interpret tracing measurements as a diagnosis.

### 4.4 Motor results and progress

- Present results with names and units users can understand.
- Distinguish measured values from derived estimates and sample data.
- Display previous sessions when they exist; show a helpful empty state when they do not.
- Compare sessions only where protocols and conditions are reasonably comparable.
- If a trend is displayed, describe it as a change in measurements, not proof of deterioration or improvement in a disease.
- Report export/sharing is optional for the MVP and must not expose private information without explicit user action.

### 4.5 MindEase wellness mode

- Provide a guided breathing exercise using an animated visual cue.
- Make the exercise comfortable, interruptible, and free of mandatory breath-holding.
- Include a short mindfulness/meditation experience; audio is optional and should not block the core app if no audio assets are available.
- Mindful tracing may be offered as a separate wellness exercise, not as a motor assessment.
- Offer optional user-reported relaxation ratings before and after a session.
- Allow users to skip ratings, stop a session, and choose an activity/duration.
- Store wellness records separately from motor-assessment attempts and metrics.
- Do not claim that MindEase treats anxiety, depression, Parkinson's disease, or any other condition.

### 4.6 Local data and privacy

- The initial MVP should work without an internet connection or server.
- Use local in-memory/sample data for prototyping; add SwiftData or an equivalent supported local persistence solution when session history is implemented.
- Do not collect real medical records, raw EEG, camera video, speech, or location for the MVP unless there is a specific requirement and appropriate consent.
- Do not place real health data, credentials, API keys, signing secrets, or tokens in Git.
- Keep Motor Health data distinct from MindEase wellness data.

## 5. Optional/future requirements

These features must be developed only after the MVP is stable and should not be implied to exist in the first release.

### 5.1 Backend and multi-user functionality

- Python FastAPI backend for authenticated APIs.
- PostgreSQL for structured metadata, account relationships, consent records, session metadata, derived features, and model metadata.
- Encrypted object storage for larger raw recordings, if approved and required; avoid storing large EEG binaries in normal database rows.
- Authentication, authorization, auditability, deletion and retention policies, and secure data transfer.

### 5.2 Consented research data contributions

- Separate, clear opt-ins for product functionality, clinical sharing, and research/model-training contributions.
- Store the consent version, scope, time, and revocation state.
- Allow ordinary app functionality even when a user declines research contribution.
- Use data minimization, pseudonymization, quality checks, a defined retention policy, and a process for handling withdrawal.
- Collect labels required by the research question; unlabelled movement features alone do not provide a supervised target.

### 5.3 Server-hosted XGBoost model

- Train and evaluate the model offline using suitable, lawfully obtained, appropriately labelled data.
- Define one target before training. A possible research objective is estimating a suitable clinician-rated motor-function outcome, if valid paired data is available.
- Choose regression for an appropriate numeric target or classification for a well-defined categorical target.
- Split data by participant to avoid participant leakage across training and evaluation sets.
- Evaluate appropriate metrics, calibration/uncertainty where relevant, subgroup performance, and independent generalization.
- Deploy only reviewed, versioned models that meet predefined criteria.
- Do not claim that XGBoost is a medical diagnostic model merely because it can return a prediction.

### 5.4 EEG/NeuroSignals

- Optional integration with a compatible EEG headset and its supported SDK or a compatible hardware abstraction library.
- Verify device availability, protocol support, SDK licensing, iOS compatibility, and whether raw signal export is permitted before selecting hardware.
- Capture only with clear consent and show signal-quality status.
- Process EEG signals with suitable filtering, artifact handling, and documented feature extraction.
- Keep EEG data separate from motor and wellness records.
- Treat any relationship between EEG features and reported relaxation as exploratory until validated.
- Never represent EEG as mind-reading or claim to infer thoughts, emotions, or diagnoses with certainty.

### 5.5 Clinician sharing and dashboard

- Explicit authorization for each clinician or recipient.
- Revocable, scoped, and preferably time-limited access.
- A future web dashboard may use React, but the iOS MVP does not require it.
- Any clinical intended use must be reviewed for applicable privacy, research, and medical-device requirements before deployment.

## 6. Success criteria

### MVP functional criteria

- The project builds and runs on a supported iOS Simulator and, when available, a test iPhone.
- The app presents working navigation to Motor Health and MindEase.
- The finger-tapping test captures actual touch events and computes consistent metrics from a known event sequence.
- The spiral-tracing test captures a path and computes documented geometry/time metrics.
- Invalid or incomplete attempts are handled without crashes or misleading results.
- MindEase can run a breathing session, allow the user to stop it, and record an optional check-in.
- Motor and wellness records are not mixed together.
- The app offers understandable empty states when there is no session history.
- No backend, headset, or trained model is necessary for the MVP to work.

### Engineering criteria

- Files follow the agreed folder structure and are included in the intended Xcode app target.
- The code builds without unresolved references or avoidable compiler warnings introduced by the change.
- Core calculations have tests or reproducible test cases.
- Git changes are reviewed, committed with meaningful messages, and pushed to the shared repository.
- No secrets or real health data are committed.

### Future ML/EEG criteria

Success requires a defined research target, suitable labelled data, documented consent, independent participant-level evaluation, transparent limitations, and approval of the intended use. A working demo or high accuracy on synthetic data is not sufficient evidence of clinical validity.

## 7. Constraints and assumptions

- The client application is native iOS, written in Swift and SwiftUI, and developed in Xcode.
- The codebase is maintained in GitHub repository `https://github.com/hiten-builds/NeuroPulseAI.git`.
- Multiple Macs may be used. Each device has its own clone; synchronization happens through Git commits, pushes, and pulls, not by sharing a live folder.
- AI coding tools may be used extensively, but all generated changes must be reviewed and built/tested.
- The initial product is a hackathon/student prototype, not a clinically validated medical device.
- Current app source files may be undergoing an organization refactor. Before moving or renaming files, inspect the actual repository and Xcode project configuration.
- The Xcode project must remain at the repository root. Swift source files belong in the inner app source tree, not inside the `.xcodeproj` package.
- Do not assume the exact iOS deployment target until it is checked in Xcode. SwiftData requires iOS 17 or later; if an older deployment target is needed, select a compatible persistence option.
- The MVP uses on-device calculations and local data. Backend, cloud database, training, and EEG hardware are future extensions.
- No clinical reference thresholds, diagnostic labels, model accuracy, or medical benefit may be invented.
- The project must remain usable without asking a user to contribute research data.

## 8. Product boundaries

NeuroPulse AI is intended to measure and display movement-task characteristics and provide general wellness exercises. It must not:

- diagnose Parkinson's disease or another condition;
- claim that changes in tapping/tracing prove progression or recovery;
- replace clinical assessment or medical advice;
- recommend medication changes;
- describe unvalidated model output as a confirmed clinical score;
- imply that EEG measures thoughts or directly reveals mental state;
- use research contribution as a condition of access to basic app features.
