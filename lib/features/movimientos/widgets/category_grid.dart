import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  final List<Widget> children;

  const CategoryGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final columns = 4;
    return SizedBox(
      height: children.length <= columns ? 125.0 : 250.0,
      child: GridView.builder(
        shrinkWrap: true,
        //physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 100,
        ),
        itemBuilder: (context, index) {
          final element = children[index];
          return element;
        },
      ),
    );
  }
}
