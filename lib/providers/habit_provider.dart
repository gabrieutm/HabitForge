import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/habit_repository.dart';
import '../models/habit.dart';
import '../services/streak_service.dart';
import '../services/notification_service.dart';

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

    // Se der erro de plataforma (ex: rodando em ambiente sem plugin nativo
    // configurado direito), nao queremos que isso quebre o salvamento do
    // habito -- por isso o try/catch aqui. Aprendi isso na marra testando.
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

  bool canToggle(Habit habit, DateTime date) {
    final today = DateTime.now();
    if (date.isAfter(DateTime(today.year, today.month, today.day))) {
      return false;
    }
    if (!habit.weekdays.contains(date.weekday)) {
      return false;
    }
    return StreakService.isWithinGracePeriod(habit, date, today) || habit.isDoneOn(date);
  }
}
