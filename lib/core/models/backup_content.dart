import 'package:control_financiero/core/database/db_init_data.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';

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
    required this.categoryTypesData,
  });

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
      movementsData: map.containsKey(BackupContentType.movements.name)
          ? List<Map<String, dynamic>>.from(
              map[BackupContentType.movements.name],
            )
          : [],
      categoriesData: map.containsKey(BackupContentType.categories.name)
          ? List<Map<String, dynamic>>.from(
              map[BackupContentType.categories.name],
            )
          : categoriasList.map((c) => c.toMap()).toList(),
      categoryTypesData: map.containsKey(BackupContentType.categoryTypes.name)
          ? List<Map<String, dynamic>>.from(
              map[BackupContentType.categoryTypes.name],
            )
          : tipoCategoriasList.map((ct) => ct.toMap()).toList(),
      budgetsData: map.containsKey(BackupContentType.budgets.name)
          ? List<Map<String, dynamic>>.from(map[BackupContentType.budgets.name])
          : [],
      budgetIncomeData: map.containsKey(BackupContentType.budgetIncome.name)
          ? List<Map<String, dynamic>>.from(
              map[BackupContentType.budgetIncome.name],
            )
          : [],
      notifitionsData: map.containsKey(BackupContentType.notifications.name)
          ? List<Map<String, dynamic>>.from(
              map[BackupContentType.notifications.name],
            )
          : [],
      remindersData: map.containsKey(BackupContentType.reminders.name)
          ? List<Map<String, dynamic>>.from(
              map[BackupContentType.reminders.name],
            )
          : [],
    );
  }

  List<Movimiento> get movements {
    return movementsData.map((m) => Movimiento.fromMap(m)).toList();
  }

  List<Categoria> get categories {
    return categoriesData.map((c) => Categoria.fromMap(c)).toList();
  }

  List<TipoCategoria> get categoryTypes {
    return categoryTypesData.map((ct) => TipoCategoria.fromMap(ct)).toList();
  }

  List<Presupuesto> get budgets {
    return budgetsData.map((p) => Presupuesto.fromMap(p)).toList();
  }

  List<IngresoPresupuestado> get budgetIncome {
    return budgetIncomeData
        .map((bi) => IngresoPresupuestado.fromMap(bi))
        .toList();
  }

  List<BudgetNotification> get budgetNotifications {
    return notifitionsData.map((n) => BudgetNotification.fromMap(n)).toList();
  }

  List<Recordatorio> get reminders {
    return remindersData.map((r) => Recordatorio.fromMap(r)).toList();
  }
}
