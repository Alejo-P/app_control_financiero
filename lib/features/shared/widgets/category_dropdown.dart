// ignore_for_file: deprecated_member_use

import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  final int selectedValue;
  final List<Categoria> categorias;
  final ValueChanged<int>? onChangeCategory;

  const CategoryDropdown({
    super.key,
    required this.selectedValue,
    required this.categorias,
    this.onChangeCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dropDownBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );

    return Expanded(
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        value: selectedValue,
        decoration: InputDecoration(
          border: dropDownBorder,
          enabledBorder: dropDownBorder,
          focusedBorder: dropDownBorder,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          filled: true,
          fillColor: colors.primary.withOpacity(0.2),
        ),
        items: categorias.map((categoria) {
          return DropdownMenuItem<int>(
            value: categoria.id!,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(categoria.iconData, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    categoria.name,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return categorias.map((categoria) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                categoria.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList();
        },
        onChanged: (value) {
          if (value == null) return;
          onChangeCategory?.call(value);
        },
      ),
    );
  }
}
