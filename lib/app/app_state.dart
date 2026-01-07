import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  int currentTab = 0;
  String currentPageName = 'Inicio';
  DateTime selectedMonth = DateTime.now();

  final List<String> pageNames = [
    'Inicio',
    'Movimientos',
    'Presupuesto',
    'Historial',
    'Ajustes',
  ];

  void changeTab(int index) {
    if (currentTab == index) return;
    
    currentTab = index;
    currentPageName = pageNames[index];
    notifyListeners();
  }

  void changeMonth(DateTime month) {
    selectedMonth = month;
    notifyListeners();
  }
}
