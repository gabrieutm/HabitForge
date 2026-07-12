import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/habit_repository.dart';
import '../models/habit.dart';
import '../services/streak_service.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart';

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

    try {
      await NotificationService.instance.scheduleForHabit(habit);
    } catch (e) {
      debugPrint('Falha ao agendar notificacao: $e');
    }

    _load();
  }

  Future<void> updateHabit(
    Habit habit, {
    required String name,
    required Set<int> weekdays,
    required int reminderHour,
    required int reminderMinute,
    required int colorValue,
  }) async {
    habit.name = name;
    habit.weekdays = weekdays;
    habit.reminderHour = reminderHour;
    habit.reminderMinute = reminderMinute;
    habit.colorValue = colorValue;
    await habit.save();

    try {
      await NotificationService.instance.scheduleForHabit(habit);
    } catch (e) {
      debugPrint('Falha ao reagendar notificacao: $e');
    }

    _load();
  }

  Future<void> deleteHabit(Habit habit) async {
    try {
      await NotificationService.instance.cancelForHabit(habit);
    } catch (e) {
      debugPrint('Falha ao cancelar notificacao: $e');
    }
    await _repository.delete(habit.id);
    _load();
  }

  Future<void> toggleToday(Habit habit) async {
    habit.toggleDate(DateTime.now());
    await habit.save();
    _load();
  }

  Future<void> toggleDate(Habit habit, DateTime date) async {
    habit.toggleDate(date);
    await habit.save();
    _load();
  }

  /// FIX: antes essa checagem comparava `date` (que pode vir com hora
  /// zerada de lugares diferentes, mas nao garantido) direto com
  /// `DateTime.now()` sem normalizar os dois. Isso deixava passar
  /// (ou bloquear) dias de forma inconsistente dependendo de com que
  /// hora exata a tela era aberta. Agora normaliza os dois lados antes
  /// de comparar. Achei isso testando manualmente perto da meia-noite.
  bool canToggle(Habit habit, DateTime date) {
    final today = DateUtils2.normalize(DateTime.now());
    final normalizedDate = DateUtils2.normalize(date);

    if (normalizedDate.isAfter(today)) {
      return false;
    }
    if (!habit.weekdays.contains(normalizedDate.weekday)) {
      return false;
    }
    return StreakService.isWithinGracePeriod(habit, normalizedDate, today) ||
        habit.isDoneOn(normalizedDate);
  }
}
