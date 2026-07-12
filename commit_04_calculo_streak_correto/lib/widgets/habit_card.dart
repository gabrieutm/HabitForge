import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: habit.isDoneToday,
          onChanged: (_) => onToggle(),
        ),
        title: Text(habit.name),
        subtitle: Text('🔥 ${habit.currentStreak} (recorde: ${habit.bestStreak})'),
      ),
    );
  }
}
