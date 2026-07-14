import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/weekday_selector.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameController = TextEditingController();
  Set<int> _weekdays = {1, 2, 3, 4, 5, 6, 7};
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome e ao menos um dia.')),
      );
      return;
    }

    context.read<HabitProvider>().addHabit(
          name: name,
          weekdays: _weekdays,
          reminderHour: _time.hour,
          reminderMinute: _time.minute,
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo habito')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do habito',
                hintText: 'Ex: Beber agua',
              ),
            ),
            const SizedBox(height: 24),
            const Text('Dias da semana'),
            const SizedBox(height: 8),
            WeekdaySelector(
              selected: _weekdays,
              onChanged: (value) => setState(() => _weekdays = value),
            ),
            const SizedBox(height: 24),
            const Text('Horario do lembrete'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _pickTime,
              child: Text(_time.format(context)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Salvar habito'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
