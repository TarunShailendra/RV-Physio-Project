import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The bladder diary a patient is part-way through, held on the device.
///
/// Three days of entries used to live only in memory, so backgrounding the app
/// discarded them. Because they now persist, clearing them on sign-out is a
/// privacy requirement rather than tidiness: the next person to use the device
/// must not find the previous patient's diary.
class DiaryDraftStore {
  static const String _key = 'bladder_diary_draft';

  static Future<void> save(Map<String, dynamic> draft) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(draft));
    } catch (e) {
      debugPrint('diary draft save failed: $e');
    }
  }

  static Future<Map<String, dynamic>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('diary draft restore failed: $e');
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('diary draft clear failed: $e');
    }
  }
}
