import 'package:flutter/material.dart';

class BottomNavigationForm extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int>? onTap;

  const BottomNavigationForm({
    super.key,
    required this.currentIndex,
    this.items = const [],
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
      items: items,
      onTap: onTap,
    );
  }
}
