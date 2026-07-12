import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/habit_repository.dart';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  final _uuid = const Uuid();

  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  HabitProvider() {
    _load();
  }

  void _load() {
    _habits = _repository.getAll();
    notifyListeners();
  }

  Future<void> addHabit({
    required String name,
    required Set<int> weekdays,
    required int reminderHour,
    required int reminderMinute,
    int colorValue = 0xFF2F6F4F,
  }) async {
    final habit = Habit(
      id: _uuid.v4(),
      name: name,
      weekdays: weekdays,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      colorValue: colorValue,
    );
    await _repository.save(habit);
    _load();
  }

  Future<void> toggleToday(Habit habit) async {
    habit.toggleDate(DateTime.now());
    await habit.save();
    _load();
  }
}
