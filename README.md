# AlgoOwl 🦉

> Duolingo-inspired mobile app for learning Data Structures & Algorithms.

## What is this?

A gamified, mobile-first DSA learning platform. Instead of typing code on a phone keyboard, users build solutions by tapping smart autofill buttons that inject language constructs into an in-app editor.

## Tech Stack

- **Frontend:** Flutter (Dart)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Backend:** FastAPI (planned — currently all data is mocked)

## Getting Started

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── theme/          # Colors, typography, spacing, theme
│   ├── widgets/        # Reusable components (OwlButton, ProgressBar, etc.)
│   └── services/       # API service (placeholder stubs)
├── features/
│   ├── onboarding/     # 4-step onboarding flow
│   ├── home/           # Home screen + AppShell (bottom nav)
│   ├── lesson/         # Lesson flow (concept → quiz → code)
│   ├── code_editor/    # Smart autofill code editor + results
│   ├── practice/       # Free practice by category/difficulty
│   ├── leaderboard/    # Weekly XP leaderboard
│   └── profile/        # User profile + settings
├── models/             # Data models (Category, Problem, UserProfile)
├── providers/          # Riverpod state providers
├── router/             # GoRouter configuration
└── main.dart           # App entry point
```

## Design

Follows the design system by Picasso:
- **Identity color:** Electric Blue (#1A8CFF)
- **Font:** Nunito (UI) + JetBrains Mono (code)
- **Style:** Duolingo DNA — rounded, gamified, 3D buttons, celebration animations

## Backend (Planned)

All API calls are stubbed in `lib/core/services/api_service.dart`. Endpoints follow the architecture doc — FastAPI backend with Docker-based code execution.

## Phase 1 MVP Scope

- [x] Onboarding flow
- [x] Home screen with skill tree
- [x] Lesson flow (concept → quiz → code editor)
- [x] Smart autofill code editor
- [x] Practice mode
- [x] Leaderboard (mock data)
- [x] Profile screen
- [ ] Backend integration
- [ ] Auth (Google/Apple sign-in)
- [ ] Real code execution
- [ ] Spaced repetition system

---

*Built by Linus 💻 · Designed by Picasso 🎨*
