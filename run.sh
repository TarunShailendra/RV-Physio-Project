#!/usr/bin/env bash
# Runs the app with the Supabase credentials the app needs at build time.
# See run.ps1 for why they are not in source. Usage: ./run.sh [flutter args]
set -euo pipefail
cd "$(dirname "$0")"

if [ ! -f supabase.env.json ]; then
  echo "supabase.env.json not found." >&2
  echo "Copy supabase.env.example.json to supabase.env.json and fill in the" >&2
  echo "two values from Supabase -> Project Settings -> API." >&2
  exit 1
fi

[ $# -eq 0 ] && set -- -d chrome
exec flutter run "$@" --dart-define-from-file=supabase.env.json
