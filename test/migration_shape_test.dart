import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The migration cannot be exercised from a Dart test, so this asserts that
/// the file still says what it must. It is a guard against an edit silently
/// dropping a clause, not a substitute for applying it: only Task 14's
/// end-to-end check proves Postgres accepts the wider session_number.
void main() {
  final sql = File(
    'supabase/migrations/20260915120000_protocol_exercise_logs.sql',
  ).readAsStringSync().toLowerCase();

  test('the session_number ceiling is raised past the old five', () {
    expect(sql, contains('session_number between 1 and 30'));
    expect(sql, contains('drop constraint if exists'));
  });

  test('exercise_key is added so a log row stays interpretable', () {
    expect(sql, contains('add column if not exists exercise_key text'));
  });

  test('rows written under the old five-per-day scheme are cleared', () {
    expect(sql, contains('delete from public.exercise_logs'));
  });

  test('the migration is safe to run twice', () {
    expect(sql, isNot(contains('add column exercise_key')));
    expect(sql, contains('drop constraint if exists'));
    expect(sql, contains('if not exists'));
  });
}
