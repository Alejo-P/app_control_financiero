import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';
import 'package:sqflite/sqflite.dart';

Future<void> upsertTipoCategoria(Database db, TipoCategoria tipo) async {
  final updated = await db.update(
    TipoCategoriasTable.table,
    tipo.toMap(),
    where: '${TipoCategoriasTable.name} = ?',
    whereArgs: [tipo.name],
  );

  if (updated == 0) {
    await db.insert(TipoCategoriasTable.table, tipo.toMap());
  }
}

Future<void> upsertCategoria(Database db, Categoria categoria) async {
  final updated = await db.update(
    CategoriasTable.table,
    categoria.toMap(),
    where: '${CategoriasTable.name} = ?',
    whereArgs: [categoria.name],
  );

  if (updated == 0) {
    await db.insert(CategoriasTable.table, categoria.toMap());
  }
}

Future<void> upsertBudgetNotification(Database db, BudgetNotification notification) async {
  final updated = await db.update(
    BudgetNotificationConfigTable.table,
    notification.toMap(),
    where: '${BudgetNotificationConfigTable.id} = ?',
    whereArgs: [notification.id],
  );

  if (updated == 0) {
    await db.insert(BudgetNotificationConfigTable.table, notification.toMap());
  }
}

Future<void> setSeedVersion(Database db, int version) async {
  await db.insert(
    MetaTable.table,
    {
      MetaTable.key: 'seed_version',
      MetaTable.value: version.toString(),
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}