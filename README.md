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
xcodebuild -project NeuroPulseAI.xcodeproj \
           -scheme NeuroPulseAI \
           -sdk iphonesimulator \
           -destination "generic/platform=iOS Simulator" \
           clean build CODE_SIGNING_ALLOWED=NO
```
