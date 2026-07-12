import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:habitforge/models/habit.dart';
import 'package:habitforge/data/habit_repository.dart';

/// Teste basico do repositorio usando uma box Hive em memoria.
/// Nao testei isso antes (commit 2) porque na hora eu queria so ver o
/// app rodando -- essa cobertura ficou pra essa leva final mesmo, junto
/// com os outros ajustes de fechamento do projeto.
void main() {
  setUp(() async {
    Hive.init('./test/.hive_test');
    Hive.registerAdapter(HabitAdapter());
    await Hive.openBox<Habit>(HabitRepository.boxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  test('salva e recupera um habito', () async {
    final repository = HabitRepository();
    final habit = Habit(
      id: '1',
      name: 'Ler 10 paginas',
      weekdays: {1, 3, 5},
      reminderHour: 20,
      reminderMinute: 30,
    );

    await repository.save(habit);
    final all = repository.getAll();

    expect(all.length, 1);
    expect(all.first.name, 'Ler 10 paginas');
  });

  test('remove um habito', () async {
    final repository = HabitRepository();
    final habit = Habit(
      id: '2',
      name: 'Meditar',
      weekdays: {1, 2, 3, 4, 5, 6, 7},
      reminderHour: 7,
      reminderMinute: 0,
    );

    await repository.save(habit);
    await repository.delete('2');

    expect(repository.getAll(), isEmpty);
  });
}
