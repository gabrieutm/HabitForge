import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

/// Tela de estatisticas simples. Nada muito sofisticado -- so numeros
/// agregados que ja tinhamos disponivel nos habitos, sem precisar de
/// nenhum calculo novo complexo.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;

    final totalHabits = habits.length;
    final bestOverall = habits.isEmpty
        ? 0
        : habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);
    final totalCompletions = habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Estatisticas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatTile(label: 'Habitos ativos', value: '$totalHabits'),
          _StatTile(label: 'Melhor streak (geral)', value: '🔥 $bestOverall'),
          _StatTile(label: 'Total de conclusoes registradas', value: '$totalCompletions'),
          const SizedBox(height: 24),
          Text('Por habito', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...habits.map((h) => ListTile(
                title: Text(h.name),
                subtitle: Text('${h.completedDates.length} conclusoes registradas'),
                trailing: Text('recorde ${h.bestStreak}'),
              )),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
