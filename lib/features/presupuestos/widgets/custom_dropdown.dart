import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String? hintText;
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemLabelBuilder;

  const CustomDropdown({
    super.key,
    this.hintText,
    required this.items,
    this.selectedItem,
    this.onChanged,
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        value: selectedItem,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabelBuilder != null
                      ? itemLabelBuilder!(item)
                      : item.toString(),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: _inputDecoration(hintText),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hintText) {
    return InputDecoration(
      hintText: hintText,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
