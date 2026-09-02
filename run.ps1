# Runs the app with the Supabase credentials the app needs at build time.
#
# The URL and anon key are not in source: they were committed to a public
# repo once and were removed. main.dart throws on startup without them,
# rather than starting and failing on the first query.
#
# Usage:  .\run.ps1              # Chrome, the usual case
#         .\run.ps1 -d windows   # any other device; flags pass straight through
#
# If supabase.env.json is missing, copy supabase.env.example.json and fill in
# the two values from Supabase -> Project Settings -> API.

$ErrorActionPreference = 'Stop'
$env_file = Join-Path $PSScriptRoot 'supabase.env.json'

if (-not (Test-Path $env_file)) {
    Write-Host "supabase.env.json not found." -ForegroundColor Red
    Write-Host "Copy supabase.env.example.json to supabase.env.json and fill in"
    Write-Host "the two values from Supabase -> Project Settings -> API."
    exit 1
}

$flutter_args = if ($args.Count -gt 0) { $args } else { @('-d', 'chrome') }
& flutter run @flutter_args "--dart-define-from-file=$env_file"
