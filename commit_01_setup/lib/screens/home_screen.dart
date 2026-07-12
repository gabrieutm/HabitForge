import 'package:flutter/material.dart';

/// Tela inicial. Por enquanto so um placeholder pra ter algo rodando
/// na tela e validar que o setup do projeto ta ok.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HabitForge')),
      body: const Center(
        child: Text('Em construcao...'),
      ),
    );
  }
}
