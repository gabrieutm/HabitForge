import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  Set<int> weekdays;

  @HiveField(3)
  int reminderHour;

  @HiveField(4)
  int reminderMinute;

  @HiveField(5)
  List<String> completedDates;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  int currentStreak;

  @HiveField(8)
  int bestStreak;

  @HiveField(9)
  int colorValue;

  Habit({
    required this.id,
    required this.name,
    required this.weekdays,
    required this.reminderHour,
    required this.reminderMinute,
    List<String>? completedDates,
    DateTime? createdAt,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.colorValue = 0xFF2F6F4F,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool get isDoneToday {
    final todayKey = _dateKey(DateTime.now());
    return completedDates.contains(todayKey);
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // TODO(commit 4): essa logica de streak e ingenua de proposito por
  // enquanto -- so incrementa um contador, sem considerar dias da semana
  // agendados nem furos reais. Vai ser substituida por um StreakService
  // com regras direito (grace period, virada de mes, etc).
  void markDoneToday() {
    final key = _dateKey(DateTime.now());
    if (!completedDates.contains(key)) {
      completedDates.add(key);
      currentStreak += 1;
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    }
  }

  void unmarkDoneToday() {
    final key = _dateKey(DateTime.now());
    if (completedDates.remove(key)) {
      if (currentStreak > 0) currentStreak -= 1;
    }
  }
}
