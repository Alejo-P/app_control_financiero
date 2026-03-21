import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/database/db_migrations.dart';
import 'package:control_financiero/core/database/db_seeds.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
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
    enabledRepeatMovement: true,
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
    enabledRepeatMovement: true,
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
    enabledRepeatMovement: true,
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
    enabledRepeatMovement: true,
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
    enabledRepeatMovement: true,
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
    enabledRepeatMovement: true,
    isDefault: true,
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
    await migrateMovimientosTable(db);
    await setSeedVersion(db, currentVersion + 1);
  }
  if (currentVersion < 5) {
    await migrateCategoriasEnabledRepeatMovement(db);
    await migrateMovimientosTable(db);
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
}
