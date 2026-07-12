import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../data/habit_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracoes')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tema escuro'),
            value: themeProvider.mode == ThemeMode.dark,
            onChanged: (_) => context.read<ThemeProvider>().toggle(),
          ),
          const Divider(),
          ListTile(
            title: const Text('Apagar todos os dados'),
            subtitle: const Text('Remove todos os habitos e historico permanentemente.'),
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            onTap: () => _confirmWipe(context),
          ),
        ],
      ),
    );
  }

  void _confirmWipe(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tem certeza?'),
        content: const Text('Essa acao vai apagar TODOS os habitos e nao pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await Hive.box(HabitRepository.boxName).clear();
              Navigator.of(dialogContext).pop();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Apagar tudo'),
          ),
        ],
      ),
    );
  }
}
