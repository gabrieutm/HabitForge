import 'package:flutter_test/flutter_test.dart';
import 'package:habitforge/models/habit.dart';
import 'package:habitforge/services/streak_service.dart';

Habit _buildHabit({
  required DateTime createdAt,
  required Set<int> weekdays,
  List<String>? completedDates,
}) {
  return Habit(
    id: 'test-id',
    name: 'Teste',
    weekdays: weekdays,
    reminderHour: 9,
    reminderMinute: 0,
    createdAt: createdAt,
    completedDates: completedDates ?? [],
  );
}

void main() {
  group('StreakService - habito diario simples', () {
    test('streak cresce a cada dia marcado consecutivo', () {
      // Criado numa segunda, marcado seg/ter/qua.
      final createdAt = DateTime(2026, 6, 1); // segunda
      final habit = _buildHabit(
        createdAt: createdAt,
        weekdays: {1, 2, 3, 4, 5, 6, 7},
        completedDates: ['2026-06-01', '2026-06-02', '2026-06-03'],
      );

      final result = StreakService.calculate(habit, now: DateTime(2026, 6, 3));
      expect(result.current, 3);
      expect(result.best, 3);
    });

    test('furo no meio quebra a streak apos o grace period expirar', () {
      final createdAt = DateTime(2026, 6, 1);
      final habit = _buildHabit(
        createdAt: createdAt,
        weekdays: {1, 2, 3, 4, 5, 6, 7},
        // pulou dia 2, marcou 1 e 3
        completedDates: ['2026-06-01', '2026-06-03'],
      );

      // "Hoje" ja passou do dia 2 (o proximo evento depois do dia 2 e dia 3,
      // entao ao chegar no dia 3 o furo do dia 2 expira).
      final result = StreakService.calculate(habit, now: DateTime(2026, 6, 3));
      expect(result.current, 1); // so o dia 3 conta, streak reiniciou
    });
  });

  group('StreakService - dias especificos da semana (grace period)', () {
    test('marcar retroativamente dentro do grace period mantem a streak', () {
      // Habito seg/qua/sex. Criado numa segunda.
      final createdAt = DateTime(2026, 6, 1); // segunda
      final habit = _buildHabit(
        createdAt: createdAt,
        weekdays: {1, 3, 5}, // seg, qua, sex
        // marcou segunda e quarta, ainda nao marcou sexta
        completedDates: ['2026-06-01', '2026-06-03'],
      );

      // "Hoje" e quinta (2026-06-04) -- ou seja, o evento de sexta (06-05)
      // ainda nao comecou, entao nao ha furo pendente ainda.
      final result = StreakService.calculate(habit, now: DateTime(2026, 6, 4));
      expect(result.current, 2);
    });

    test('evento perdido pode ser salvo ate o proximo evento comecar', () {
      final createdAt = DateTime(2026, 6, 1); // segunda
      final habit = _buildHabit(
        createdAt: createdAt,
        weekdays: {1, 3, 5},
        // marcou segunda, esqueceu quarta, mas marcou retroativamente
        // ANTES de sexta comecar
        completedDates: ['2026-06-01', '2026-06-03'],
      );

      final result = StreakService.calculate(habit, now: DateTime(2026, 6, 5));
      // Sexta ja comecou (06-05), entao o evento de quarta (06-03) foi
      // cumprido a tempo (esta na lista) -- streak intacta contando os 3.
      expect(result.current, 2); // sexta ainda nao foi marcada
    });

    test('evento perdido expira quando o proximo evento comeca sem ter sido marcado', () {
      final createdAt = DateTime(2026, 6, 1); // segunda
      final habit = _buildHabit(
        createdAt: createdAt,
        weekdays: {1, 3, 5},
        // marcou segunda, NAO marcou quarta a tempo
        completedDates: ['2026-06-01', '2026-06-05'],
      );

      // Hoje e sexta, o evento de quarta ja expirou (o de sexta comecou)
      // e nao foi cumprido -> streak quebra, reinicia na sexta.
      final result = StreakService.calculate(habit, now: DateTime(2026, 6, 5));
      expect(result.current, 1);
    });
  });

  group('StreakService - virada de mes/ano (bug que me pegou de verdade)', () {
    test('streak nao quebra so por causa da virada do mes', () {
      // Esse teste existe porque na primeira versao eu comparava strings
      // de data em vez de DateTime normalizado e a ordenacao de
      // "2026-01-31" vs "2026-02-01" as vezes vinha errada dependendo de
      // como a lista era montada. Deixei o teste pra nunca mais acontecer.
      final createdAt = DateTime(2026, 1, 29); // quinta
      final habit = _buildHabit(
        createdAt: createdAt,
        weekdays: {1, 2, 3, 4, 5, 6, 7},
        completedDates: ['2026-01-29', '2026-01-30', '2026-01-31', '2026-02-01', '2026-02-02'],
      );

      final result = StreakService.calculate(habit, now: DateTime(2026, 2, 2));
      expect(result.current, 5);
    });

    test('streak nao quebra na virada de ano', () {
      final createdAt = DateTime(2025, 12, 30);
      final habit = _buildHabit(
        createdAt: createdAt,
        weekdays: {1, 2, 3, 4, 5, 6, 7},
        completedDates: ['2025-12-30', '2025-12-31', '2026-01-01', '2026-01-02'],
      );

      final result = StreakService.calculate(habit, now: DateTime(2026, 1, 2));
      expect(result.current, 4);
    });
  });

  group('StreakService - bestStreak', () {
    test('bestStreak guarda o maior valor mesmo depois de quebrar', () {
      final createdAt = DateTime(2026, 6, 1);
      final habit = _buildHabit(
        createdAt: createdAt,
        weekdays: {1, 2, 3, 4, 5, 6, 7},
        // 3 dias seguidos, furo, 1 dia
        completedDates: ['2026-06-01', '2026-06-02', '2026-06-03', '2026-06-05'],
      );

      final result = StreakService.calculate(habit, now: DateTime(2026, 6, 5));
      expect(result.current, 1);
      expect(result.best, 3);
    });
  });
}
