import 'package:flutter/material.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/storage/app_database.dart';
import '../../note/models/note.dart';

class HabitsNotifier extends ChangeNotifier {
  final StorageService _storage;

  List<Habit> _allHabits = [];
  List<HabitCompletion> _allCompletions = [];
  List<Note> _notes = [];
  int _themeMode = 0;
  bool _isFirstTimeUser = true;

  HabitsNotifier(this._storage);

  List<Habit> get allHabits => _allHabits;
  List<HabitCompletion> get allCompletions => _allCompletions;
  List<Note> get notes => _notes;
  int get themeMode => _themeMode;
  bool get isFirstTimeUser => _isFirstTimeUser;

  Future<void> loadData() async {
    await _storage.init();
    _themeMode = _storage.getThemeMode();
    _isFirstTimeUser = _storage.isFirstTimeUser();
    _notes = _storage.getAllNotes();
    await refreshHabits();
  }

  Future<void> refreshHabits() async {
    _allHabits = await _storage.getAllHabits();
    _allCompletions = await _storage.getAllCompletions();
    notifyListeners();
  }

  // Getters for filtered lists (Ongoing, Upcoming, Past)
  List<Habit> get ongoingHabits {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allHabits.where((h) {
      final start = DateTime(h.startDate.year, h.startDate.month, h.startDate.day);
      if (h.isLifelong) {
        return start.isBefore(today) || start.isAtSameMomentAs(today);
      } else if (h.endDate != null) {
        final end = DateTime(h.endDate!.year, h.endDate!.month, h.endDate!.day);
        return (start.isBefore(today) || start.isAtSameMomentAs(today)) &&
            (end.isAfter(today) || end.isAtSameMomentAs(today));
      }
      return false;
    }).toList();
  }

  List<Habit> get upcomingHabits {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allHabits.where((h) {
      final start = DateTime(h.startDate.year, h.startDate.month, h.startDate.day);
      return start.isAfter(today);
    }).toList();
  }

  List<Habit> get pastHabits {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allHabits.where((h) {
      if (h.isLifelong || h.endDate == null) return false;
      final end = DateTime(h.endDate!.year, h.endDate!.month, h.endDate!.day);
      return end.isBefore(today);
    }).toList();
  }

  // Check duplicate name
  bool isHabitNameDuplicate(String name, {int? excludeId}) {
    return _allHabits.any((h) =>
        (excludeId == null || h.id != excludeId) &&
        h.name.trim().toLowerCase() == name.trim().toLowerCase());
  }

  // Add Habit
  Future<void> addHabit({
    required String name,
    String? description,
    required int iconCodePoint,
    required int colorHex,
    required bool isLifelong,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    await _storage.createHabit(
      name.trim(),
      description,
      iconCodePoint,
      colorHex,
      isLifelong,
      startDate,
      endDate,
    );
    await refreshHabits();
  }

  // Update Habit
  Future<void> updateHabit({
    required int id,
    required String name,
    String? description,
    required int iconCodePoint,
    required int colorHex,
    required bool isLifelong,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final habit = Habit(
      id: id,
      name: name.trim(),
      description: description,
      iconCodePoint: iconCodePoint,
      colorHex: colorHex,
      isLifelong: isLifelong,
      startDate: startDate,
      endDate: endDate,
    );
    await _storage.updateHabit(habit);
    await refreshHabits();
  }

  // Delete Habit
  Future<void> deleteHabit(int id) async {
    await _storage.deleteHabit(id);
    await refreshHabits();
  }

  // Toggle completion
  Future<void> toggleCompletion(int habitId, DateTime date) async {
    await _storage.toggleCompletion(habitId, date);
    await refreshHabits();
  }

  // Check completion
  bool isCompleted(int habitId, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _allCompletions.any((c) =>
        c.habitId == habitId &&
        c.completedDate.year == dateOnly.year &&
        c.completedDate.month == dateOnly.month &&
        c.completedDate.day == dateOnly.day);
  }

  List<DateTime> getCompletedDates(int habitId) {
    return _allCompletions
        .where((c) => c.habitId == habitId)
        .map((c) => c.completedDate)
        .toList();
  }

  // Backup and Restore Helpers
  String exportBackupData() {
    return _storage.exportBackup(_allHabits, _allCompletions);
  }

  Future<void> importBackupData(String jsonStr) async {
    await _storage.importBackup(jsonStr);
    await refreshNotes();
    await refreshHabits();
  }

  // Notes Operations
  Future<void> refreshNotes() async {
    _notes = _storage.getAllNotes();
    notifyListeners();
  }

  Future<void> addNote({
    required String heading,
    required String body,
    required int colorHex,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: now.millisecondsSinceEpoch.toString(),
      heading: heading,
      body: body,
      colorHex: colorHex,
      createdAt: now,
      updatedAt: now,
    );
    final list = _storage.getAllNotes();
    list.add(note);
    await _storage.saveNotes(list);
    await refreshNotes();
  }

  Future<void> updateNote(Note note) async {
    final list = _storage.getAllNotes();
    final idx = list.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      list[idx] = note.copyWith(updatedAt: DateTime.now());
      await _storage.saveNotes(list);
      await refreshNotes();
    }
  }

  Future<void> deleteNote(String id) async {
    final list = _storage.getAllNotes();
    list.removeWhere((n) => n.id == id);
    await _storage.saveNotes(list);
    await refreshNotes();
  }

  // Themes & Settings
  Future<void> changeThemeMode(int mode) async {
    _themeMode = mode;
    await _storage.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> completeFirstTimeUser() async {
    _isFirstTimeUser = false;
    await _storage.setFirstTimeUser(false);
    notifyListeners();
  }
}
