import 'package:flutter/material.dart';

class GridContainer extends StatelessWidget {
  final int columns;
  final double gap;
  final List<Widget> children;

  const GridContainer({
    super.key,
    required this.columns,
    required this.children,
    this.gap = 8.0,
  });

  @override
  Widget build(BuildContext context) {

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: gap,
      mainAxisSpacing: gap,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
