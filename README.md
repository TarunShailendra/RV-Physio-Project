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

- **Clinically gated assessment flow** — Patients progress through a sequenced set of validated questionnaires, with each stage unlocking only upon completion of its prerequisite:
  - **ICIQ** (International Consultation on Incontinence Questionnaire) — entry point; always accessible
  - **IPAQ** (International Physical Activity Questionnaire) — unlocked after ICIQ completion
  - **IQOL** (Incontinence Quality of Life) — unlocked after ICIQ + IPAQ and completion of the 7-day exercise protocol
- **Exercise protocol tracking** — Records exercise logs to Supabase (`exercise_logs`), tracks protocol start date, monitors daily completion, and programmatically determines patient eligibility for reassessment
- **Bladder diary** — Full save/load support with persistent Supabase-backed storage
- **Route-level access control** — Dashboard, exercise, bladder diary, education, and reassessment routes are protected via `GoRouter` redirect guards; unauthorized access is redirected to the appropriate prerequisite
- **Session persistence** — Assessment results and exercise progress are restored from Supabase on startup and login, ensuring continuity across sessions
- **Profile management** — Patient profiles are persisted to Supabase with conditional fields (e.g. pain-level input displayed only when clinically indicated)
- **Flexible authentication** — Supports sign-up and login via phone number or email; email is treated as optional, with a generated placeholder used internally when omitted
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
   Add your Supabase project URL and anon key to your environment or configuration file as required by the project setup.

4. **Apply database migrations**
   ```bash
   # Using the Supabase CLI
   supabase db push
   ```
   Migration files are located in `supabase/migrations/`.

5. **Run the application**
   ```bash
   flutter run
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
