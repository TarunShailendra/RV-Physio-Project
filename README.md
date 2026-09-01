# TeleRehab App

A Flutter-based telerehabilitation platform for pelvic floor / postpartum physiotherapy, built with a Supabase backend. The app guides patients through a structured assessment-and-exercise protocol — from initial intake questionnaires to a supervised 7‑day exercise program and outcome reassessment.

## Features

- **Guided assessment flow** — Patients progress through a gated sequence of standardized questionnaires:
  - **ICIQ** (Incontinence Questionnaire) — always accessible, entry point to the app
  - **IPAQ** (International Physical Activity Questionnaire) — unlocked after ICIQ
  - **IQOL** (Incontinence Quality of Life) — unlocked after ICIQ + IPAQ and a completed 7‑day exercise protocol
- **Exercise protocol tracking** — Tracks protocol start date and exercise progress; automatically determines when a patient becomes eligible for reassessment
- **Route guarding** — Dashboard, exercise, bladder diary, education, and reassessment routes are protected via `GoRouter` redirects until prerequisite assessments are complete
- **Bladder diary & education modules**
- **Profile management** — Persisted patient profile with conditional fields (e.g. pain-level tracking shown only when clinically relevant)
- **Flexible authentication** — Sign up/login via phone or email, with email treated as optional

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Routing | [GoRouter](https://pub.dev/packages/go_router) |
| State management | [Provider](https://pub.dev/packages/provider) |
| UI | Material 3 (custom teal theme) |
| Backend | [Supabase](https://supabase.com/) (auth, database) |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- A [Supabase](https://supabase.com/) project

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/TarunShailendra/RV-Physio-Project.git
   cd RV-Physio-Project
   ```
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Configure Supabase credentials (URL and anon key) in your environment/config setup
4. Apply database migrations found in `supabase/migrations/`
5. Run the app
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── app.dart              # App entry point, GoRouter route configuration & redirect logic
├── screens/
│   └── assessment_screen.dart  # Assessment flow UI with lock/completed status tiles
├── providers/
│   └── exercise_notifier.dart  # Tracks protocol start date & exercise progress
└── ...
supabase/
└── migrations/           # Database schema & migration files
```

## Assessment Flow Logic

The app enforces a clinical assessment sequence via route guards:

1. **ICIQ** — always available
2. **IPAQ** — requires ICIQ completion; gates access to dashboard, exercise, bladder diary, education, and reassessment
3. **7-day exercise protocol** — tracked from protocol start date
4. **IQOL** — becomes available once ICIQ + IPAQ are complete and the 7-day exercise protocol has elapsed

## Roadmap

- [ ] Persist exercise week progress to Supabase/local storage
- [ ] Admin login and role-based access
- [ ] "Change email" functionality
- [ ] Additional outcome tracking and reporting

## Contributing

Contributions are welcome. Please open an issue to discuss significant changes before submitting a pull request.

## License

Add your license here (e.g. MIT).
