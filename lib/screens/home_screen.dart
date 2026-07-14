import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;

    return Scaffold(
      appBar: AppBar(title: const Text('HabitForge')),
      body: habits.isEmpty
          ? const Center(child: Text('Nenhum habito cadastrado ainda.'))
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return HabitCard(
                  habit: habit,
                  onToggle: () => context.read<HabitProvider>().toggleToday(habit),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddHabitScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
