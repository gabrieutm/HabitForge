import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onOpen,
        leading: Checkbox(
          value: habit.isDoneToday,
          onChanged: (_) => onToggle(),
        ),
        title: Text(habit.name),
        subtitle: Text('🔥 ${habit.currentStreak} (recorde: ${habit.bestStreak})'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
