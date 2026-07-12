import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/date_utils.dart';
import 'add_habit_screen.dart';

/// Tela de detalhe/historico do habito. Mostra os ultimos 35 dias como
/// uma grade simples (nao e um calendario "de verdade" com mes por mes --
/// decidi nao gastar tempo com isso agora, uma grade linear ja resolve
/// o essencial: ver o padrao de conclusao recente e marcar dias
/// retroativos dentro do grace period).
class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final today = DateTime.now();
    final days = List.generate(35, (i) => DateUtils2.normalize(today.subtract(Duration(days: 34 - i))));

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddHabitScreen(habitToEdit: habit)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('🔥 Streak atual: ${habit.currentStreak}', style: Theme.of(context).textTheme.titleLarge),
          Text('🏆 Recorde: ${habit.bestStreak}'),
          const SizedBox(height: 24),
          const Text('Ultimos 35 dias'),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final scheduled = habit.weekdays.contains(day.weekday);
              final done = habit.isDoneOn(day);
              final canToggle = provider.canToggle(habit, day);

              Color color;
              if (!scheduled) {
                color = Colors.transparent;
              } else if (done) {
                color = Color(habit.colorValue);
              } else {
                color = Colors.grey.shade300;
              }

              return GestureDetector(
                onTap: scheduled && canToggle
                    ? () => context.read<HabitProvider>().toggleDate(habit, day)
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: scheduled ? null : Border.all(color: Colors.grey.shade200),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 11,
                      color: done ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Dias marcados em cinza ainda podem ser preenchidos ate o proximo '
            'dia agendado comecar (grace period). Depois disso o quadrado fica '
            'travado e conta como falha.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir habito?'),
        content: Text('Isso vai apagar "${habit.name}" e todo o historico. Essa acao nao pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<HabitProvider>().deleteHabit(habit);
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
