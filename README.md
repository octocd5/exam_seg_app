# Bubble

Bubble is a distraction-blocking and study tracking application built with Flutter. It enforces focus sessions by locking distracting applications with an Android system overlay and requires visual verification via on-device machine learning to stop sessions.

## Overview

The application is designed for exam preparation, deep work, and distraction-free study blocks. During an active focus session, distracting apps are monitored and blocked using a system alert overlay. Sessions can only be stopped after scanning and verifying a designated physical target object (such as a book, mug, or laptop) through the camera using Google ML Kit.

## Key Features

- Focus Chronometer: Real-time tracking of study sessions with dynamic state management and visual progress.
- Camera Verification: AI-powered object recognition using Google ML Kit to unlock and conclude active focus blocks.
- Distraction Overlay: Android system-level overlay service that intercepts designated restricted apps while the timer is running.
- Customizable Block Lists: Create and manage custom app lists, with support for standard list blocking or phone-wide restrictions.
- Automated Routines: Set up recurring daily or weekly focus schedules with customizable start times and flexible end conditions (specific end time or until manually stopped).
- Activity Insights: Comprehensive logs of focus time, 7-day distribution charts, daily session history, and unlock verification records.
- Multilingual Support: Built-in internationalization supporting English and Spanish with runtime language switching.
- Persistent Storage: State preservation across app launches using SharedPreferences.

## Technology Stack

- Framework: Flutter (Dart 3)
- State Management: Riverpod
- Machine Learning: Google ML Kit (Image Labeling)
- Camera & Hardware: Camera Plugin, Android System Alert Window
- Local Storage: SharedPreferences
- Design & Typography: Average Sans (Google Fonts), Lottie Animations

## Getting Started

### Prerequisites

- Flutter SDK (version 3.13.4 or higher)
- Android SDK (API level 24 or higher recommended)
- Java Development Kit (JDK 17 or higher)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd exam_seg_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

### Building for Release

To build a release APK:
```bash
flutter build apk --release
```

To build split per-ABI release APKs:
```bash
flutter build apk --split-per-abi
```

### Running Tests

Execute the automated test suite:
```bash
flutter test
```

Check code quality and static analysis:
```bash
flutter analyze
```

## Project Structure

```
lib/
├── core/
│   ├── constants/       # Color tokens, styles, and asset references
│   └── localization/    # Bilingual strings (English and Spanish) and locale controller
├── features/
│   ├── activity/        # Activity logs, analytics charts, and session models
│   ├── camera/          # ML Kit camera detection and verification screen
│   ├── lists/           # Custom block list manager and models
│   ├── schedules/       # Automated routines, schedule models, and controller
│   ├── settings/        # App preferences, language selection, and permissions
│   └── timer/           # Focus chronometer, overlay service bridge, and state
└── main.dart            # Application entry point and theme configuration
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
