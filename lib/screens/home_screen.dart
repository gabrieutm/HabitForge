import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/habit_repository.dart';
import '../models/habit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitRepository _repository = HabitRepository();
  final _uuid = const Uuid();

  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    setState(() {
      _habits = _repository.getAll();
    });
  }

  // TODO: remover isso quando a tela de criacao de habito existir (commit 3).
  // Botao so pra validar que salvar/ler do Hive ta funcionando.
  Future<void> _seedTestHabit() async {
    final habit = Habit(
      id: _uuid.v4(),
      name: 'Beber agua',
      weekdays: {1, 2, 3, 4, 5, 6, 7},
      reminderHour: 9,
      reminderMinute: 0,
    );
    await _repository.save(habit);
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HabitForge')),
      body: _habits.isEmpty
          ? const Center(child: Text('Nenhum habito cadastrado ainda.'))
          : ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return ListTile(
                  title: Text(habit.name),
                  subtitle: Text('Streak atual: ${habit.currentStreak}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _seedTestHabit,
        child: const Icon(Icons.add),
      ),
    );
  }
}
