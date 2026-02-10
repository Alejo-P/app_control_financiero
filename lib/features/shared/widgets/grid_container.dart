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
    final height = children.length <= columns ? 125.0 : 250.0;
    if (children.length == 1) {
      return Center(child: children.first);
    }

    return SizedBox(
      height: height,
      child: GridView.count(
        crossAxisCount: columns,
        childAspectRatio: 0.9,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        children: children,
      ),
    );
  }
}
