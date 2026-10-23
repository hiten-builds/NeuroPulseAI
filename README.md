# NeuroPulse AI

NeuroPulse AI is a native iOS healthcare and wellness application built using Swift and SwiftUI, designed to support neurological health monitoring, motor assessments, and mindful wellness.

---

## Architecture & Project Structure

The project uses Xcode's modern **Filesystem Synchronized Root Group** (`PBXFileSystemSynchronizedRootGroup`), introduced in Xcode 16. Any files or folders added under the inner `NeuroPulseAI/` source directory are automatically discovered and included in the application target.

```
NeuroPulseAI/
├── .gitignore
├── README.md
├── NeuroPulseAI.xcodeproj/
└── NeuroPulseAI/
    ├── App/
    │   └── NeuroPulseAIApp.swift
    ├── Core/
    │   ├── DesignSystem/
    │   ├── Components/
    │   └── Utilities/
    ├── Features/
    │   ├── Home/
    │   │   └── HomeView.swift
    │   ├── MotorHealth/
    │   │   ├── Views/
    │   │   ├── Models/
    │   │   ├── Services/
    │   │   └── Components/
    │   ├── MindEase/
    │   │   ├── Views/
    │   │   ├── Models/
    │   │   └── Components/
    │   └── Progress/
    ├── Data/
    │   ├── Models/
    │   └── Storage/
    └── Resources/
        ├── Assets.xcassets/
        └── Audio/
```

### Folder Definitions

- **App/**: Application entry point (`NeuroPulseAIApp.swift`), root lifecycle, and app-wide initialization.
- **Core/**: Reusable foundation code across features:
  - `DesignSystem/`: Colors, typography, spacing tokens, and themes.
  - `Components/`: Shared UI components (custom buttons, cards, progress bars).
  - `Utilities/`: Extensions, helpers, formatting tools, and constants.
- **Features/**: Feature-driven functional modules:
  - `Home/`: Main dashboard, welcome overview, and primary navigation (`HomeView.swift`).
  - `MotorHealth/`: Finger-tapping tests, spiral tracing, calculations, and result scoring.
  - `MindEase/`: Guided breathing, meditation, mindful tracing, and wellness check-ins.
  - `Progress/`: Historical assessments, trend visualization, and analytics charts.
- **Data/**: Application state persistence and shared data layer:
  - `Models/`: Shared data models and entities.
  - `Storage/`: Local persistence abstractions and storage implementations.
- **Resources/**: Application assets, media, and catalogs:
  - `Assets.xcassets/`: App icons, accent colors, and graphic assets.
  - `Audio/`: Sound effects, guided meditation tracks, and audio prompts.

---

## Requirements & Environment

- **Platform**: iOS 18.0+ / iPadOS 18.0+ (Deployment target: iOS 27.0 tools standard)
- **Language**: Swift 5 / Swift 6 approachable concurrency
- **IDE**: Xcode 16.0+

---

## Building and Verification

### Using Xcode
1. Open `NeuroPulseAI.xcodeproj` in Xcode.
2. Select an iOS Simulator (e.g., iPhone 16) or connected device.
3. Press `Cmd + B` to build or `Cmd + R` to run.

### Using Command Line
```bash
# Clean and build iOS application
xcodebuild -project NeuroPulseAI.xcodeproj -scheme NeuroPulseAI -destination 'platform=iOS Simulator,id=ACTUAL_SIMULATOR_ID' clean build

# Run automated iOS tests
xcodebuild -project NeuroPulseAI.xcodeproj -scheme NeuroPulseAI -destination 'platform=iOS Simulator,id=ACTUAL_SIMULATOR_ID' test
```

---

## Phase 7A: Account Authentication, Data Consent, and Recommendations

NeuroPulseAI Phase 7A introduces a privacy-first account foundation with two equally supported operating modes:

### Operating Modes
1. **Mode A — Data Sharing Consented**: User creates an account or signs in. When explicit, purpose-specific consent (`v1.0`) is granted for personalization, newly completed assessment and wellness records synchronize securely to the FastAPI backend. Explainable recommendations with evidence metrics are generated. Users can inspect or withdraw consent and request remote data deletion in Settings.
2. **Mode B — Local-Only Operation**: User selects "Continue Locally" without creating an account. All motor health assessments (two-zone tapping with center deviation, spiral tracing) and MindEase wellness activities remain 100% functional, saved locally on-device. Zero activity records are uploaded to the cloud.

### Backend Setup (`backend/`)
The backend is built with FastAPI, SQLAlchemy (SQLite default for local dev, PostgreSQL ready), Argon2id password hashing, and PyJWT authentication.

```bash
# 1. Create and activate virtual environment
python3 -m venv backend/.venv
source backend/.venv/bin/activate

# 2. Install dependencies
pip install -r backend/requirements.txt

# 3. Configure environment
cp backend/.env.example backend/.env

# 4. Run backend automated tests (14 tests covering auth, consent, sync idempotency, user isolation, recommendations)
PYTHONPATH=. pytest backend/tests -v

# 5. Start development backend server (accessible to iOS Simulator at http://127.0.0.1:8000)
uvicorn backend.app.main:app --host 127.0.0.1 --port 8000
```

Verify backend health at `http://127.0.0.1:8000/health`.

