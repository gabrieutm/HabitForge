import 'package:hive/hive.dart';

part 'habit.g.dart';

/// Representa um habito rastreavel.
///
/// [weekdays] usa a convencao do DateTime.weekday (1 = segunda ... 7 = domingo),
/// guardado como Set pra facilitar checagem de "hoje e dia agendado?".
///
/// [completedDates] guarda as datas (normalizadas para meia-noite, sem hora)
/// em que o habito foi marcado como concluido. Formato ISO8601 (string) porque
/// Hive lida melhor com tipos simples do que com DateTime em alguns cenarios
/// de migracao futura -- decisao meio defensiva, talvez exagero, mas evita dor de cabeca.
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
}
