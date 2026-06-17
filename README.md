# ⚡ VibeStudy

**Premium AI-powered Study Companion — Flutter App**

---

## ✨ Features

| Feature | Description |
|---|---|
| 🏠 **Dashboard** | Hero greeting, XP bar, streaks, quick stats, today's tasks |
| 📅 **Study Planner** | Task management with priorities, due dates & progress tracking |
| ⏱ **Focus Timer** | Pomodoro-style timer with animated ring, session logging, XP rewards |
| 📝 **Notes** | Rich note-taking with subjects, colors, pin & search |
| 🃏 **Flashcards** | Deck builder with flip animations and confidence tracking |
| 📡 **Revision Radar** | Weekly bar charts, subject breakdown, session history |
| 🗺 **Mind Maps** | Visual mind map builder with interactive viewer |
| 👤 **Profile** | XP leveling, achievement badges, stats overview, rewards system |

---

## 🚀 Getting Started

### Requirements
- Flutter SDK `>=3.10.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code
- Android SDK 21+ / iOS 12+

### Installation

```bash
# Clone or extract the project
cd vibestudy

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build Release APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

---

## 🏗 Project Structure

```
lib/
├── core/
│   ├── constants/    # App-wide constants
│   ├── theme/        # Colors, typography, Material3 theme
│   └── utils/        # Helper functions
├── data/
│   ├── models/       # Data models (User, Note, Flashcard, Task…)
│   └── providers/    # AppProvider (ChangeNotifier state management)
├── features/
│   ├── dashboard/    # Home shell + Dashboard + Splash
│   ├── planner/      # Study Planner
│   ├── timer/        # Pomodoro Focus Timer
│   ├── notes/        # Notes
│   ├── flashcards/   # Flashcard Decks + Study Mode
│   ├── radar/        # Revision Radar / Analytics
│   ├── mindmap/      # Mind Map Builder + Viewer
│   └── profile/      # Profile + XP + Rewards
└── shared/
    └── widgets/      # Reusable UI components
```

---

## 🎨 Design System

- **Color Palette:** Deep navy, indigo, electric blue, purple accents
- **Typography:** Sora font family (Google Fonts)
- **Components:** GlassCard, GradientButton, XPBar, StatChip, EmptyState
- **Animations:** flutter_animate — fade, slide, scale transitions
- **Charts:** fl_chart — bar charts for weekly study data

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.1 | State management |
| `shared_preferences` | ^2.2.2 | Local persistence |
| `uuid` | ^4.3.3 | Unique IDs |
| `fl_chart` | ^0.68.0 | Study analytics charts |
| `flutter_animate` | ^4.5.0 | Smooth animations |
| `percent_indicator` | ^4.2.3 | Progress indicators |
| `google_fonts` | ^6.2.1 | Sora typography |
| `lottie` | ^3.1.0 | Lottie animations |
| `shimmer` | ^3.0.0 | Loading shimmer |
| `confetti` | ^0.7.0 | Celebration effects |

---

## 📱 Build Targets

- **Android:** minSdk 21, targetSdk 34, compileSdk 34
- **iOS:** iOS 12.0+
- **Orientation:** Portrait only

---

## 🏆 XP & Leveling System

| Action | XP Earned |
|---|---|
| Focus Session | +50 XP |
| Note Created | +20 XP |
| Task Completed | +30 XP |
| Flashcard Added | +10 XP |
| Daily Streak | +100 XP |

**Levels:** 500 XP per level — Novice → Learner → Scholar → Expert → Master → Legend

---

Built with ❤️ using Flutter & Material 3
