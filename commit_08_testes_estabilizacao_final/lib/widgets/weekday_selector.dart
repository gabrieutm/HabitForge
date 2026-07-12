import 'package:flutter/material.dart';

/// Selecionador de dias da semana (1 = segunda ... 7 = domingo, seguindo
/// DateTime.weekday). Feito na unha com Wrap+ChoiceChip pra nao trazer
/// mais uma dependencia so pra isso.
class WeekdaySelector extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  const WeekdaySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final weekday = index + 1;
        final isSelected = selected.contains(weekday);
        return ChoiceChip(
          label: Text(_labels[index]),
          selected: isSelected,
          onSelected: (value) {
            final updated = Set<int>.from(selected);
            if (value) {
              updated.add(weekday);
            } else {
              updated.remove(weekday);
            }
            onChanged(updated);
          },
        );
      }),
    );
  }
}
