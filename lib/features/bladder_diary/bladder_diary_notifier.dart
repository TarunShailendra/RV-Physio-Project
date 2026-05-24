import 'package:flutter/foundation.dart';

import 'models/diary_entry.dart';

class BladderDiaryNotifier extends ChangeNotifier {
  final List<DiaryDay> days = [];

  bool get isComplete =>
      days.length == 3 && days.every((day) => day.entries.length >= 3);

  void addEntry(DiaryEntry entry) {
    final today = _dateOnly(DateTime.now());
    final dayIndex = days.indexWhere((day) => _isSameDate(day.date, today));

    if (dayIndex == -1) {
      if (days.length >= 3) {
        return;
      }

      days.add(
        DiaryDay(
          date: today,
          entries: [entry],
        ),
      );
    } else {
      final day = days[dayIndex];
      days[dayIndex] = DiaryDay(
        date: day.date,
        entries: [...day.entries, entry],
      );
    }

    notifyListeners();
  }

  void removeEntry(int dayIndex, int entryIndex) {
    if (dayIndex < 0 || dayIndex >= days.length) {
      return;
    }

    final day = days[dayIndex];
    if (entryIndex < 0 || entryIndex >= day.entries.length) {
      return;
    }

    final entries = [...day.entries]..removeAt(entryIndex);
    days[dayIndex] = DiaryDay(date: day.date, entries: entries);
    notifyListeners();
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void reset() {
    days.clear();
    notifyListeners();
  }
}