import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import 'app_database.dart';
import '../../features/note/models/note.dart';

class StorageService {
  final AppDatabase? _db;
  late final SharedPreferences _prefs;

  StorageService(this._db);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Web Helper Methods for JSON persistence
  List<Habit> _getWebHabits() {
    final raw = _prefs.getStringList('web_habits') ?? [];
    return raw.map((str) => Habit.fromJson(jsonDecode(str) as Map<String, dynamic>)).toList();
  }

  Future<void> _saveWebHabits(List<Habit> habits) async {
    final list = habits.map((h) => jsonEncode(h.toJson())).toList();
    await _prefs.setStringList('web_habits', list);
  }

  List<HabitCompletion> _getWebCompletions() {
    final raw = _prefs.getStringList('web_completions') ?? [];
    return raw.map((str) => HabitCompletion.fromJson(jsonDecode(str) as Map<String, dynamic>)).toList();
  }

  Future<void> _saveWebCompletions(List<HabitCompletion> completions) async {
    final list = completions.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList('web_completions', list);
  }

  // Habits CRUD
  Future<int> createHabit(
    String name,
    String? description,
    int iconCodePoint,
    int colorHex,
    bool isLifelong,
    DateTime startDate,
    DateTime? endDate,
  ) async {
    if (kIsWeb) {
      final habits = _getWebHabits();
      final id = habits.isEmpty ? 1 : habits.map((h) => h.id).reduce((a, b) => a > b ? a : b) + 1;
      final newHabit = Habit(
        id: id,
        name: name,
        description: description,
        iconCodePoint: iconCodePoint,
        colorHex: colorHex,
        isLifelong: isLifelong,
        startDate: startDate,
        endDate: endDate,
      );
      habits.add(newHabit);
      await _saveWebHabits(habits);
      return id;
    } else {
      final companion = HabitsCompanion.insert(
        name: name,
        description: description != null ? Value(description) : const Value.absent(),
        iconCodePoint: iconCodePoint,
        colorHex: colorHex,
        isLifelong: Value(isLifelong),
        startDate: startDate,
        endDate: endDate != null ? Value(endDate) : const Value.absent(),
      );
      return await _db!.into(_db.habits).insert(companion);
    }
  }

  Future<List<Habit>> getAllHabits() async {
    if (kIsWeb) {
      return _getWebHabits();
    } else {
      return await _db!.select(_db.habits).get();
    }
  }

  Future<void> deleteHabit(int id) async {
    if (kIsWeb) {
      final habits = _getWebHabits();
      habits.removeWhere((h) => h.id == id);
      await _saveWebHabits(habits);

      // Cascade delete completions on Web
      final completions = _getWebCompletions();
      completions.removeWhere((c) => c.habitId == id);
      await _saveWebCompletions(completions);
    } else {
      await (_db!.delete(_db.habits)..where((tbl) => tbl.id.equals(id))).go();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    if (kIsWeb) {
      final habits = _getWebHabits();
      final idx = habits.indexWhere((h) => h.id == habit.id);
      if (idx != -1) {
        habits[idx] = habit;
        await _saveWebHabits(habits);
      }
    } else {
      await _db!.update(_db.habits).replace(habit);
    }
  }

  // Completions
  Future<List<HabitCompletion>> getAllCompletions() async {
    if (kIsWeb) {
      return _getWebCompletions();
    } else {
      return await _db!.select(_db.habitCompletions).get();
    }
  }

  Future<void> toggleCompletion(int habitId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (kIsWeb) {
      final completions = _getWebCompletions();
      final idx = completions.indexWhere((c) =>
          c.habitId == habitId &&
          c.completedDate.year == dateOnly.year &&
          c.completedDate.month == dateOnly.month &&
          c.completedDate.day == dateOnly.day);

      if (idx != -1) {
        completions.removeAt(idx);
      } else {
        final id = completions.isEmpty ? 1 : completions.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
        completions.add(HabitCompletion(
          id: id,
          habitId: habitId,
          completedDate: dateOnly,
        ));
      }
      await _saveWebCompletions(completions);
    } else {
      final query = _db!.select(_db.habitCompletions)
        ..where((tbl) => tbl.habitId.equals(habitId) & tbl.completedDate.equals(dateOnly));
      final existing = await query.getSingleOrNull();

      if (existing != null) {
        await (_db.delete(_db.habitCompletions)..where((tbl) => tbl.id.equals(existing.id))).go();
      } else {
        await _db.into(_db.habitCompletions).insert(
          HabitCompletionsCompanion.insert(
            habitId: habitId,
            completedDate: dateOnly,
          ),
        );
      }
    }
  }

  // Settings
  static const _keyThemeMode = 'theme_mode';
  static const _keyFirstTime = 'is_first_time';

  Future<void> saveThemeMode(int mode) async {
    await _prefs.setInt(_keyThemeMode, mode);
  }

  int getThemeMode() {
    return _prefs.getInt(_keyThemeMode) ?? 0;
  }

  Future<void> setFirstTimeUser(bool isFirstTime) async {
    await _prefs.setBool(_keyFirstTime, isFirstTime);
  }

  bool isFirstTimeUser() {
    return _prefs.getBool(_keyFirstTime) ?? true;
  }

  // Backup Export & Import
  String exportBackup(List<Habit> habits, List<HabitCompletion> completions) {
    final habitsJson = habits.map((h) => h.toJson()).toList();
    final completionsJson = completions.map((c) => c.toJson()).toList();
    final notesJson = getAllNotes().map((n) => n.toJson()).toList();
    final data = {
      'version': 2,
      'habits': habitsJson,
      'completions': completionsJson,
      'notes': notesJson,
    };
    return jsonEncode(data);
  }

  Future<void> importBackup(String jsonStr) async {
    final Map<String, dynamic> data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final List<dynamic> habitsRaw = data['habits'] as List<dynamic>;
    final List<dynamic> completionsRaw = data['completions'] as List<dynamic>;
    final List<dynamic>? notesRaw = data['notes'] as List<dynamic>?;

    final List<Habit> habits = habitsRaw.map((h) => Habit.fromJson(h as Map<String, dynamic>)).toList();
    final List<HabitCompletion> completions = completionsRaw.map((c) => HabitCompletion.fromJson(c as Map<String, dynamic>)).toList();

    if (kIsWeb) {
      await _saveWebHabits(habits);
      await _saveWebCompletions(completions);
    } else {
      final database = _db!;
      await database.transaction(() async {
        await database.delete(database.habitCompletions).go();
        await database.delete(database.habits).go();

        for (final h in habits) {
          await database.into(database.habits).insert(h.toCompanion(true));
        }
        for (final c in completions) {
          await database.into(database.habitCompletions).insert(c.toCompanion(true));
        }
      });
    }

    if (notesRaw != null) {
      final List<Note> notes = notesRaw.map((n) => Note.fromJson(n as Map<String, dynamic>)).toList();
      await saveNotes(notes);
    }
  }

  // Notes Storage Helpers
  List<Note> getAllNotes() {
    final raw = _prefs.getStringList('app_notes') ?? [];
    return raw.map((str) => Note.fromJson(jsonDecode(str) as Map<String, dynamic>)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveNotes(List<Note> notes) async {
    final list = notes.map((n) => jsonEncode(n.toJson())).toList();
    await _prefs.setStringList('app_notes', list);
  }
}
