import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  final List<Widget> children;

  const CategoryGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final element = children[index];
          return element;
        },
      ),
    );
  }
}
