import 'package:flutter/material.dart';
import '../../colors/colors.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.2),
        border: Border.all(color: AppColors.darkGrey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: TextStyle(color: AppColors.black)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: AppColors.black)),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: AppColors.white,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.darkBlue),
        ),
      ),
    );
  }
}
