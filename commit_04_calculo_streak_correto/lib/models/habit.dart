import 'package:hive/hive.dart';
import '../services/streak_service.dart';
import '../utils/date_utils.dart';

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

  bool get isDoneToday => completedDates.contains(DateUtils2.toKey(DateTime.now()));

  bool isDoneOn(DateTime date) => completedDates.contains(DateUtils2.toKey(date));

  /// Marca/desmarca um dia especifico como concluido e recalcula a streak
  /// usando o StreakService. Substitui a logica ingenua do commit anterior.
  void toggleDate(DateTime date) {
    final key = DateUtils2.toKey(date);
    if (completedDates.contains(key)) {
      completedDates.remove(key);
    } else {
      completedDates.add(key);
    }
    _recalculateStreak();
  }

  void _recalculateStreak() {
    final result = StreakService.calculate(this);
    currentStreak = result.current;
    if (result.best > bestStreak) {
      bestStreak = result.best;
    }
  }
}
