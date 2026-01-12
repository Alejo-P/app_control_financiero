import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/categorias/widgets/category_card_detail.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:flutter/material.dart';

class CategoryContainer extends StatelessWidget {
  final String categoryName;
  final List<Categoria> categorias;

  const CategoryContainer({
    super.key,
    required this.categoryName,
    required this.categorias,
  });

  @override
  Widget build(BuildContext context) {
    final cantidadCategorias = categorias.length;

    return WidgetsContainer(
      title: categoryName,
      summaryAmount: cantidadCategorias == 1
          ? '$cantidadCategorias categoría'
          : '$cantidadCategorias categorías',
      summaryAmountStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
      children: categorias.map((categoria) {
        return CategoryCardDetail(
          name: categoria.name,
          description: categoria.description,
          icon: categoria.iconData,
          color: categoria.iconColor,
          isDefault: categoria.isDefault,
        );
      }).toList(),
    );
  }
}
