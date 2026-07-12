import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:habitforge/models/habit.dart';
import 'package:habitforge/data/habit_repository.dart';
import 'package:habitforge/providers/habit_provider.dart';
import 'package:habitforge/screens/home_screen.dart';

/// Teste de widget simples so pra garantir que a tela inicial nao quebra
/// ao renderizar com lista vazia e com um habito cadastrado. Nao cobre
/// notificacao (plugin nativo nao roda em ambiente de teste) nem
/// navegacao completa -- ficou como TODO pra uma proxima rodada de testes
/// se o projeto continuar evoluindo.
void main() {
  setUp(() async {
    Hive.init('./test/.hive_test_widget');
    Hive.registerAdapter(HabitAdapter());
    await Hive.openBox<Habit>(HabitRepository.boxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('mostra estado vazio quando nao ha habitos', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HabitProvider(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Nenhum habito cadastrado ainda.'), findsOneWidget);
  });

  testWidgets('mostra o habito cadastrado na lista', (tester) async {
    final repository = HabitRepository();
    await repository.save(Habit(
      id: 'x',
      name: 'Alongamento',
      weekdays: {1, 2, 3, 4, 5},
      reminderHour: 8,
      reminderMinute: 0,
    ));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HabitProvider(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Alongamento'), findsOneWidget);
  });
}
