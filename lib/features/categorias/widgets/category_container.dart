import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/categorias/widgets/category_card_detail.dart';
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                categoryName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                cantidadCategorias == 1
                    ? '$cantidadCategorias categoría'
                    : '$cantidadCategorias categorías',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categorias.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return CategoryCardDetail(
                name: categoria.name,
                description: categoria.description,
                icon: categoria.iconData,
                color: categoria.iconColor,
                isDefault: categoria.isDefault,
              );
            },
          ),
        ],
      ),
    );
  }
}
