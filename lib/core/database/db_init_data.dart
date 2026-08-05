import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/database/db_migrations.dart';
import 'package:control_financiero/core/database/db_seeds.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification.dart';
import 'package:control_financiero/features/notificaciones/models/movement_notification_config.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';
import 'package:sqflite/sqflite.dart';

final tipoCategoriasList = <TipoCategoria>[
  TipoCategoria(
    id: 1,
    name: 'Gastos escenciales',
    description: 'Gastos relacionados con alimentos y necesidades básicas',
  ),
  TipoCategoria(
    id: 2,
    name: 'Estilo de vida',
    description: 'Gastos relacionados con actividades recreativas y ocio',
  ),
  TipoCategoria(
    id: 3,
    name: 'Ahorro e inversión',
    description: 'Gastos relacionados con ahorro e inversiones',
  ),
];

final categoriasList = <Categoria>[
  Categoria(
    id: 1,
    name: 'Vivienda',
    description: 'Gastos relacionados con el hogar y la vivienda',
    movementType: TipoMovimiento.gasto,
    categoryTypeID: 1,
    iconName: 'home',
    iconColorValue: 0xFF42A5F5,
    isDefault: true,
  ),
  Categoria(
    id: 2,
    name: 'Alimentos',
    description: 'Gastos en comida y supermercado',
    movementType: TipoMovimiento.gasto,
    categoryTypeID: 1,
    iconName: 'restaurant',
    iconColorValue: 0xFFEF5350,
    isDefault: true,
  ),
  Categoria(
    id: 3,
    name: 'Transporte',
    description: 'Gastos en transporte público y gasolina',
    movementType: TipoMovimiento.gasto,
    categoryTypeID: 1,
    iconName: 'directions_bus',
    iconColorValue: 0xFFFF9800,
    isDefault: true,
  ),
  Categoria(
    id: 4,
    name: 'Trabajo',
    description: 'Ingresos relacionados con el trabajo',
    movementType: TipoMovimiento.ingreso,
    categoryTypeID: 3,
    iconName: 'payments',
    iconColorValue: 0xFF4CAF50,
    isDefault: true,
  ),
  Categoria(
    id: 5,
    name: 'Salud',
    description: 'Gastos en salud y bienestar',
    movementType: TipoMovimiento.gasto,
    categoryTypeID: 2,
    iconName: 'local_hospital',
    iconColorValue: 0xFFAB47BC,
    isDefault: true,
  ),
  Categoria(
    id: 6,
    name: 'Ocio',
    description: 'Gastos en actividades recreativas y entretenimiento',
    movementType: TipoMovimiento.gasto,
    categoryTypeID: 2,
    iconName: 'movie',
    iconColorValue: 0xFFFF7043,
    isDefault: true,
  ),
];

final presupuestosNotif = [
  BudgetNotification(
    id: 1,
    threshold: 0.5, // 50% del presupuesto
    isEnabledNotification: true,
    isDefault: true,
    createdAt: DateTime.now(),
  ),
  BudgetNotification(
    id: 2,
    threshold: 0.85, // 85% del presupuesto
    isEnabledNotification: true,
    isDefault: true,
    createdAt: DateTime.now(),
  ),
  BudgetNotification(
    id: 3,
    threshold: 1.0, // 100% del presupuesto
    isEnabledNotification: true,
    isDefault: true,
    createdAt: DateTime.now(),
  ),
];

final movementNotificationConfigs = [
  MovementNotificationConfig(
    id: 1,
    typeKey: MovementNotificationConfig.createMovementKey,
    isEnabled: false,
    isDefault: true,
    createdAt: DateTime.now(),
  ),
  MovementNotificationConfig(
    id: 2,
    typeKey: MovementNotificationConfig.editMovementKey,
    isEnabled: false,
    isDefault: true,
    createdAt: DateTime.now(),
  ),
  MovementNotificationConfig(
    id: 3,
    typeKey: MovementNotificationConfig.deleteMovementKey,
    isEnabled: false,
    isDefault: true,
    createdAt: DateTime.now(),
  ),
];

Future<void> runSeeds(Database db) async {
  await createTables(db);
  final result = await db.query(
    MetaTable.table,
    where: '${MetaTable.key} = ?',
    whereArgs: ['seed_version'],
  );

  final currentVersion = result.isEmpty
      ? 0
      : int.parse(result.first['value'] as String);

  if (currentVersion < 1) {
    for (var tipo in tipoCategoriasList) {
      await upsertTipoCategoria(db, tipo);
    }

    for (var categoria in categoriasList) {
      await upsertCategoria(db, categoria);
    }
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 2) {
    await migrateMovimientosAmount(db);
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 3) {
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 4) {
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 5) {
    for (var categoria in categoriasList) {
      await upsertCategoria(db, categoria);
    }
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 6) {
    await migratePresupuestosRepeatBudget(db);
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 7) {
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 8) {
    await migrateNotificationsCreatedAt(db);
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 9) {
    for (var notif in presupuestosNotif) {
      await upsertBudgetNotification(db, notif);
    }
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 10) {
    await setSeedVersion(db, currentVersion + 1);
    await migrateNotificationsType(db);
  }
  if (currentVersion < 11) {
    await migrateNotificationsObjectId(db);
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 12) {
    for (var config in movementNotificationConfigs) {
      await upsertMovementNotificationConfig(db, config);
    }
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 13) {
    await migrateRemoveObsoleteColumns(db);
    await setSeedVersion(db, currentVersion + 1);
  }
}
