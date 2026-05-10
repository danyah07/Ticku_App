# Ticku 🏆

> Compete with friends through shared challenges and daily tasks.

Ticku is an iOS app that helps friend groups stay accountable by competing through shared challenges. Each user manages their own private to-do list while seeing friends' progress in real time — without ever seeing their tasks.

---

## Features

- **Shared Challenges** — Create a challenge, set a duration, and invite friends to join
- **Private Task Lists** — Each member manages their own tasks; no one else can see them
- **Live Leaderboard** — Track everyone's progress as a percentage in real time
- **Winning Streak System** — Stay consistent and build your streak across challenges
- **Challenge History** — Track how many challenges you've completed over time
- **Profile Management** — Edit your name and profile picture at any time
- **Sign in with Apple** — Fast, private, and secure authentication

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Architecture | MVVM |
| Database | Firebase Firestore |
| Authentication | Firebase Auth + Sign in with Apple |
| Onboarding Tips | TipKit |
| Notifications | UserNotifications framework |
| Accessibility | VoiceOver support |
| Localization | English + Arabic |

---

## Project Structure

```
Ticku/
├── App/                        # Entry point and AppDelegate
├── Core/
│   ├── Navigation/             # NavigationManager + AppRoute
│   ├── ErrorHandling/          # AppError + ErrorHandler
│   ├── Notifications/          # NotificationManager
│   ├── Localization/           # Localizable.xcstrings + LanguageManager
│   └── Accessibility/          # VoiceOverHelper
├── Modules/
│   ├── Authentication/         # Sign in with Apple
│   ├── Profile/                # View and edit profile
│   ├── Challenges/             # Create, browse, and view challenges
│   ├── Tasks/                  # Private per-user task lists
│   ├── Leaderboard/            # Real-time progress ranking
│   └── Streak/                 # Streak tracking and badges
├── Shared/
│   ├── Components/             # Reusable UI components
│   ├── Extensions/             # SwiftUI + Foundation helpers
│   └── TipKit/                 # In-app tips
└── Resources/
    ├── Assets.xcassets
    ├── en.lproj/
    └── ar.lproj/
```

---

## Database Structure

```
Firestore
│
├── users/{userId}
│   ├── displayName
│   ├── profileImageURL
│   ├── currentStreak
│   ├── longestStreak
│   └── totalChallengesCompleted
│
└── challenges/{challengeId}
    ├── title, status, createdBy
    ├── startDate, endDate
    ├── members/{userId}          ← public progress only
    │   └── progressPercent
    └── tasks/{taskId}            ← 🔒 private per user
        └── ownerId, title, isCompleted
```

---

## Security

- Tasks are **only readable by their owner** — enforced at the Firestore security rules level, not just the UI
- Members can see each other's **progress percentage only** — never task content
- Authentication is handled entirely through **Sign in with Apple + Firebase Auth**

---

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Firebase project with Firestore and Authentication enabled
- Sign in with Apple capability enabled in your Apple Developer account

---


## Localization

Ticku supports:
- 🇺🇸 English
- 🇸🇦 Arabic


---
## Preview
soon




