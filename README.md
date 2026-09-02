# TeleRehab App

A Flutter-based telerehabilitation platform designed to support pelvic floor and postpartum physiotherapy. Built on a Supabase backend, the application guides patients through a clinically structured protocol — encompassing validated intake assessments, a supervised 7-day exercise programme, and outcome-based reassessment — with all data persisted and restored across sessions.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Assessment Flow](#assessment-flow)
- [Changelog](#changelog)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Authenticated access** — Only the sign-in and sign-up screens are reachable without a session. Every other route, including all six questionnaire paths, requires a signed-in patient; the guard re-runs on sign-in, sign-out and protocol progress
- **Clinically gated assessment flow** — Patients progress through a sequenced set of validated questionnaires, with each stage unlocking only upon completion of its prerequisite:
  - **ICIQ** (International Consultation on Incontinence Questionnaire) — entry point; always accessible
  - **IPAQ** (International Physical Activity Questionnaire) — unlocked after ICIQ completion
  - **IQOL** (Incontinence Quality of Life) — unlocked after ICIQ + IPAQ, a completed exercise week, and seven elapsed days since the protocol began
- **Exercise protocol tracking** — Records exercise logs to Supabase (`exercise_logs`), derives the protocol start date from the earliest completed session, cues each repetition's hold and rest, and gates I-QOL eligibility on both completion and elapsed time
- **Assessment-driven start week** — ICIQ severity, IPAQ activity level and I-QOL score select the week a patient begins at, so a milder, more active patient skips the beginner weeks
- **Bladder diary** — Three days of entries kept on the device as they are typed and restored on reopen, then submitted to Supabase. A failed submission says so and keeps the entries rather than reporting success
- **Route-level access control** — A single policy in `lib/core/routing/redirect_policy.dart` decides every route, evaluated as authentication first and the assessment sequence second
- **Session persistence** — Assessment results and exercise progress are restored from Supabase on startup and login, ensuring continuity across sessions
- **Profile management** — Patient profiles are persisted to Supabase with conditional fields (e.g. pain-level input displayed only when clinically indicated)
- **Authentication** — Email and password. A real address is required: password reset and confirmation depend on it
- **Bilingual** — English and Kannada throughout, with an in-app language picker on the profile screen
- **Education module** — In-app educational content gated to appropriately progressed patients

---

## Tech Stack

| Layer            | Technology                                                   |
|------------------|--------------------------------------------------------------|
| Framework        | [Flutter](https://flutter.dev/) (stable channel)            |
| Routing          | [GoRouter](https://pub.dev/packages/go_router)              |
| State Management | [Provider](https://pub.dev/packages/provider)               |
| UI               | Material 3 — custom teal theme with glassmorphism accents   |
| Backend          | [Supabase](https://supabase.com/) (Auth + PostgreSQL)       |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — stable channel recommended
- A configured [Supabase](https://supabase.com/) project (URL and anon key required)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/TarunShailendra/RV-Physio-Project.git
   cd RV-Physio-Project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase credentials**
   Credentials are supplied at build time and are not committed. Copy the
   example file and fill it in:
   ```bash
   cp supabase.env.example.json supabase.env.json
   ```
   `supabase.env.json` is gitignored.

4. **Apply database migrations**
   ```bash
   # Using the Supabase CLI
   supabase db push
   ```
   Migration files are located in `supabase/migrations/` and cover every table
   the app reads or writes. They are idempotent, so they are safe to re-run.

   Pushing to a project whose migration history predates these files may need
   `supabase db push --include-all`, because `20260525082000_create_profiles.sql`
   is dated before an existing migration that alters the table it creates.

5. **Run the application**
   ```bash
   flutter run --dart-define-from-file=supabase.env.json
   ```

6. **Run the tests**
   ```bash
   flutter test
   ```

---

## Project Structure

```
lib/
├── app.dart                    # App entry point; GoRouter configuration and redirect logic
├── screens/
│   ├── assessment_screen.dart  # Assessment flow UI with lock/completed status tiles
│   ├── exercise_screen.dart    # Exercise protocol UI and progress display
│   ├── dashboard_screen.dart   # Patient dashboard with progress-aware state
│   ├── bladder_diary_screen.dart
│   └── profile_screen.dart
├── providers/
│   └── exercise_notifier.dart  # Protocol start date tracking and IQOL eligibility logic
├── models/                     # Data models (assessment payloads, profile, exercise logs)
└── services/                   # Supabase service layer (auth, CRUD operations)

supabase/
└── migrations/                 # Versioned database schema and migration files
```

---

## Assessment Flow

The application enforces a strict clinical progression via route-level guards:

```
ICIQ  ──►  IPAQ  ──►  7-Day Exercise Protocol  ──►  IQOL (Reassessment)
 ▲
 │
Always accessible (entry point)
```

| Stage                  | Prerequisite                        | Gates Access To                                          |
|------------------------|-------------------------------------|----------------------------------------------------------|
| ICIQ                   | None                                | IPAQ                                                     |
| IPAQ                   | ICIQ completed                      | Dashboard, Exercise, Bladder Diary, Education            |
| 7-Day Exercise Protocol| ICIQ + IPAQ completed               | IQOL availability                                        |
| IQOL                   | ICIQ + IPAQ + 7-day protocol elapsed| Reassessment and outcome tracking                        |

---

## Changelog

### Recent Updates

- **Supabase persistence for assessments** — ICIQ, IPAQ, and IQOL results are now inserted/upserted to Supabase with corrected schema-aligned payloads; completed assessment state is restored on startup and login
- **Exercise log persistence** — Daily exercise progress is loaded from and upserted to the `exercise_logs` table; dashboard state updates dynamically based on completed exercise days
- **Bladder diary persistence** — Diary entries are fully saved to and loaded from Supabase
- **Profile enhancements** — Optional gender field added to the profile model and persisted accordingly
- **Assessment query fix** — `checkCompletedAssessments()` corrected to use `limit(1)` for accurate single-record retrieval
- **iOS and static analysis fixes** — Resolved iOS-specific build issues and addressed Flutter analyzer warnings
- **Merge conflict resolution** — Conflicts resolved while preserving local UI rewrites
- **Navigation improvements** — Updated navigation flows across assessment and exercise screens; back buttons migrated to `context.pop()`
- **UI and model refinements** — Multiple updates across the dashboard, profile, assessment, exercise, and bladder diary modules

---

## Roadmap

- [ ] Admin login and role-based access control
- [ ] "Change email" functionality for authenticated users
- [ ] Extended outcome tracking and clinical reporting views
- [ ] Offline mode with local-first sync

---

## Contributing

Contributions are welcome. Please open an issue to discuss any significant changes prior to submitting a pull request. For bug reports, include steps to reproduce and relevant logs.

---

## License

This project is licensed under the [MIT License](LICENSE).
