# Pitakap — Your Wallet, Tracked

A personal money tracker that puts your complete spending picture in one app: log daily expenses in seconds, keep every subscription and bill in one place, and get reminded before renewals hit your account.

> *Pitaka* is Tagalog for wallet. Pitakap = Pitaka + App.

## Features

- 🔐 Authentication — Email/Password + Google Sign-In (Firebase Auth)
- 💳 Subscription tracking — full CRUD with billing cycles and due-date math
- 🧾 Daily expense logging — two-tap entry, per-day view with date strip
- 📊 Dashboard & stats — spent today, monthly commitments, category donut chart
- 🔔 Due-date reminders — scheduled local notifications, 100% serverless
- 🌙 Dark mode — light/dark/system, persisted
- 📡 Offline-first — Firestore offline persistence, syncs when back online

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter · Dart |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| State management | Riverpod (AsyncNotifier + sealed states) |
| Architecture | Clean Architecture (`core/` + `feature/<name>/data · domain · presentation`) |
| Notifications | flutter_local_notifications + timezone |
| Charts | fl_chart |
| Navigation | go_router |

## Architecture

```
pitakapflutter/
└── lib/
    ├── core/          shared infrastructure (error, usecase, resources, router, theme, providers)
    └── feature/       vertical slices, each split into data / domain / presentation
```

Presentation → domain ← data. External services (Firestore, notifications) are only ever touched inside datasources. Errors surface as sealed `Failure` types, caught by `AsyncValue.guard` in controllers, rendered from sealed state classes.

## Decisions & Tradeoffs

_To be filled in as the project progresses._

## Getting Started

The Flutter app lives in [`pitakapflutter/`](pitakapflutter).

```
cd pitakapflutter
flutter pub get
flutter run
```

Requires a configured Firebase project (`flutterfire configure`).
