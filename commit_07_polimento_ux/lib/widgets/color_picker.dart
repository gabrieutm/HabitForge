import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ColorPickerRow extends StatelessWidget {
  final int selectedValue;
  final ValueChanged<int> onChanged;

  const ColorPickerRow({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppColors.habitPalette.map((color) {
        final isSelected = color.value == selectedValue;
        return GestureDetector(
          onTap: () => onChanged(color.value),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
