import 'package:control_financiero/core/database/db_init_data.dart';

enum BackupContentType {
  movements,
  categories,
  categoryTypes,
  budgets,
  budgetIncome,
  notifications,
  reminders,
}

class BackupContent {
  List<Map<String, dynamic>> movementsData;
  List<Map<String, dynamic>> categoriesData;
  List<Map<String, dynamic>> categoryTypesData;
  List<Map<String, dynamic>> budgetsData;
  List<Map<String, dynamic>> budgetIncomeData;
  List<Map<String, dynamic>> notifitionsData;
  List<Map<String, dynamic>> remindersData;

  BackupContent({
    required this.movementsData,
    required this.categoriesData,
    required this.budgetsData,
    required this.budgetIncomeData,
    required this.notifitionsData,
    required this.remindersData,
    this.categoryTypesData = const [],
  }) {
    if (categoriesData.isEmpty) {
      categoriesData = categoriasList.map((c) => c.toMap()).toList();
    }
    if (categoryTypesData.isEmpty) {
      categoryTypesData = tipoCategoriasList.map((ct) => ct.toMap()).toList();
    }
    if (notifitionsData.isEmpty) {
      notifitionsData = presupuestosNotif.map((n) => n.toMap()).toList();
    }
    if (remindersData.isEmpty) {
      remindersData = defaultReminders.map((r) => r.toMap()).toList();
    }
    if (movementsData.isEmpty) {
      movementsData = [];
    }
    if (budgetsData.isEmpty) {
      budgetsData = [];
    }
    if (budgetIncomeData.isEmpty) {
      budgetIncomeData = [];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      BackupContentType.movements.name: movementsData,
      BackupContentType.categories.name: categoriesData,
      BackupContentType.categoryTypes.name: categoryTypesData,
      BackupContentType.budgets.name: budgetsData,
      BackupContentType.budgetIncome.name: budgetIncomeData,
      BackupContentType.notifications.name: notifitionsData,
      BackupContentType.reminders.name: remindersData,
    };
  }

  factory BackupContent.fromMap(Map<String, dynamic> map) {
    return BackupContent(
      movementsData: List<Map<String, dynamic>>.from(
        map[BackupContentType.movements.name] ?? [],
      ),
      categoriesData: List<Map<String, dynamic>>.from(
        map[BackupContentType.categories.name] ?? [],
      ),
      categoryTypesData: List<Map<String, dynamic>>.from(
        map[BackupContentType.categoryTypes.name] ?? [],
      ),
      budgetsData: List<Map<String, dynamic>>.from(
        map[BackupContentType.budgets.name] ?? [],
      ),
      budgetIncomeData: List<Map<String, dynamic>>.from(
        map[BackupContentType.budgetIncome.name] ?? [],
      ),
      notifitionsData: List<Map<String, dynamic>>.from(
        map[BackupContentType.notifications.name] ?? [],
      ),
      remindersData: List<Map<String, dynamic>>.from(
        map[BackupContentType.reminders.name] ?? [],
      ),
    );
  }
}
