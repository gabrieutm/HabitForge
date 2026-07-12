import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2F6F4F);
  static const Color background = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B6B6F);

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFF2F2F2);
  static const Color textSecondaryDark = Color(0xFFA0A0A3);

  /// Paleta fixa de cores selecionaveis pra cada habito. Simples e
  /// suficiente, nao precisa de um color picker completo pra um app assim.
  static const List<Color> habitPalette = [
    Color(0xFF2F6F4F), // verde (padrao)
    Color(0xFF3B6EA5), // azul
    Color(0xFFB5533C), // terracota
    Color(0xFF8E5AA0), // roxo
    Color(0xFFC98A2C), // ambar
    Color(0xFF4A9B8E), // teal
    Color(0xFFD1495B), // vermelho suave
    Color(0xFF6B6B6F), // cinza neutro
  ];
}
