import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/string_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/categorias/models/detalle_categoria.dart';
import 'package:sqflite/sqflite.dart';

class CategoriasLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;
  final Database? _database;

  CategoriasLocalDataSource({Database? database}) : _database = database;

  // Obtener todas las categorías
  Future<List<Categoria>> fetchAllCategorias() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          c.*, 
          (SELECT COUNT(*) FROM ${MovimientosTable.table} m WHERE m.${MovimientosTable.categoryId} = c.${CategoriasTable.id}) AS movements_count
        FROM ${CategoriasTable.table} c
        ORDER BY c.${CategoriasTable.name} ASC
      ''');

    return maps.map(Categoria.fromMap).toList();
  }

  Future<List<Categoria>> fetchAllNoDefaultCategorias() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          c.*, 
          (SELECT COUNT(*) FROM ${MovimientosTable.table} m WHERE m.${MovimientosTable.categoryId} = c.${CategoriasTable.id}) AS movements_count
        FROM ${CategoriasTable.table} c
        WHERE c.${CategoriasTable.isDefault} = 0
        ORDER BY c.${CategoriasTable.name} ASC
      ''');

    return maps.map(Categoria.fromMap).toList();
  }

  // Obtener una categoría por su ID
  Future<Categoria?> fetchCategoriaById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT 
          c.*, 
          (SELECT COUNT(*) FROM ${MovimientosTable.table} m WHERE m.${MovimientosTable.categoryId} = c.${CategoriasTable.id}) AS movements_count
        FROM ${CategoriasTable.table} c
        WHERE c.${CategoriasTable.id} = ?
      ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return Categoria.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<DetalleCategoria?> fetchDetalleCategoriaById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT 
          c.id AS id,
          c.name AS name,
          c.description AS description,
          c.icon_name AS icon,
          c.icon_color_value AS color,
          c.movement_type AS movementType,
          c.is_default AS isDefault,
          ct.name AS categoryTypeName,
          ct.id AS categoryTypeID,
          (SELECT COUNT(*) FROM ${MovimientosTable.table} m WHERE m.${MovimientosTable.categoryId} = c.${CategoriasTable.id}) AS totalMovements
        FROM ${CategoriasTable.table} c
        JOIN ${TipoCategoriasTable.table} ct ON c.${CategoriasTable.categoryTypeId} = ct.${TipoCategoriasTable.id}
        WHERE c.${CategoriasTable.id} = ?
      ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return DetalleCategoria.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Agregar una nueva categoría
  Future<OperationResult<int>> addCategoria(Categoria categoria) async {
    final db = await _dbHelper.database;

    // Comprobar si ya existe una categoría con el mismo nombre (ignorando mayúsculas y minúsculas)
    final categoryName = capitalize(categoria.name.trim());
    final List<Map<String, dynamic>> existing = await db.query(
      CategoriasTable.table,
      where: '${CategoriasTable.name} = ? ',
      whereArgs: [categoryName],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return OperationResult<int>(
        success: false,
        message: 'Ya existe una categoría con el nombre \'$categoryName\'.',
      );
    }

    final newCategory = categoria.copyWith(name: categoryName);
    final id = await db.insert(CategoriasTable.table, newCategory.toMap());

    return OperationResult<int>(
      success: id > 0,
      message: id > 0
          ? 'Categoría agregada exitosamente.'
          : 'Error al agregar la categoría.',
      data: id > 0 ? id : null,
    );
  }

  Future<int> countMovimientosByCategoria(int categoriaId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM ${MovimientosTable.table} WHERE ${MovimientosTable.categoryId} = ?',
      [categoriaId],
    );

    final count = Sqflite.firstIntValue(result) ?? 0;

    return count;
  }

  // Actualizar una categoría existente
  Future<OperationResult<void>> updateCategoria(Categoria categoria) async {
    final db = await _dbHelper.database;

    // Comprobar si ya existe una categoría con el mismo nombre
    final categoryName = capitalize(categoria.name.trim());
    final List<Map<String, dynamic>> existing = await db.query(
      CategoriasTable.table,
      where:
          '${CategoriasTable.name} = ? '
          'AND ${CategoriasTable.id} != ?',
      whereArgs: [categoryName, categoria.id],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return OperationResult<void>(
        success: false,
        message: 'Ya existe otra categoría con el nombre \'$categoryName\'.',
      );
    }

    // Comprobar que la categoría no es predeterminada
    final List<Map<String, dynamic>> maps = await db.query(
      CategoriasTable.table,
      where: '${CategoriasTable.id} = ?',
      whereArgs: [categoria.id],
    );

    if (maps.isNotEmpty && maps.first[CategoriasTable.isDefault] == 1) {
      // No actualizar si es predeterminada
      return OperationResult<void>(
        success: false,
        message: 'No se puede actualizar una categoría predeterminada.',
      );
    }

    // Si la categoria tiene movimientos asociados, no permitir cambiar el tipo de movimiento
    final movimientoCount = await countMovimientosByCategoria(categoria.id!);
    final existingCategoria = await fetchCategoriaById(categoria.id!);
    if (movimientoCount > 0 &&
        existingCategoria != null &&
        existingCategoria.movementType != categoria.movementType) {
      return OperationResult<void>(
        success: false,
        message:
            'No se puede cambiar el tipo de movimiento de esta categoría. Tiene $movimientoCount${movimientoCount == 1 ? ' movimiento asociado.' : ' movimientos asociados.'}',
      );
    }

    final newCategory = categoria.copyWith(name: categoryName);
    final result = await db.update(
      CategoriasTable.table,
      newCategory.toMap(),
      where: '${CategoriasTable.id} = ?',
      whereArgs: [categoria.id],
    );

    return OperationResult<void>(
      success: result > 0,
      message: result > 0
          ? 'Categoría actualizada exitosamente.'
          : 'Error al actualizar la categoría.',
    );
  }

  // Eliminar una categoría por su ID
  Future<OperationResult<void>> deleteCategoria(int id) async {
    try {
      final db = _database ?? await _dbHelper.database;
      return await db.transaction((txn) async {
        final categories = await txn.query(
          CategoriasTable.table,
          where: 'id = ?',
          whereArgs: [id],
        );
        if (categories.isEmpty) {
          return OperationResult<void>(
            success: false,
            message: 'No se encontró la categoría.',
          );
        }
        if (categories.first[CategoriasTable.isDefault] == 1) {
          return OperationResult<void>(
            success: false,
            message: 'No se puede eliminar una categoría predeterminada.',
          );
        }
        // Check every foreign key inside the same transaction as the delete.
        const relations = {
          MovimientosTable.table: 'movimientos',
          PresupuestosTable.table: 'presupuestos',
          RecordatorioTable.table: 'recordatorios',
          BudgetNotificationEventsTable.table:
              'eventos de alertas de presupuesto',
        };
        for (final relation in relations.entries) {
          final references = await txn.query(
            relation.key,
            columns: ['id'],
            where: 'category_id = ?',
            whereArgs: [id],
            limit: 1,
          );
          if (references.isNotEmpty) {
            return OperationResult<void>(
              success: false,
              message:
                  'No se puede eliminar esta categoría. Tiene ${relation.value} asociados.',
            );
          }
        }
        final count = await txn.delete(
          CategoriasTable.table,
          where: 'id = ?',
          whereArgs: [id],
        );
        return OperationResult<void>(
          success: count > 0,
          message: count > 0
              ? 'Categoría eliminada exitosamente.'
              : 'No se encontró la categoría.',
        );
      });
    } on Exception {
      return OperationResult<void>(
        success: false,
        message: 'No se pudo eliminar la categoría. Inténtalo nuevamente.',
      );
    }
  }

  Future<OperationResult<int>> deleteAllCategorias() async {
    final db = await _dbHelper.database;
    final result = await db.delete(CategoriasTable.table);

    return OperationResult<int>(
      success: result > 0,
      data: result,
      message: result > 0
          ? 'Todas las categorías eliminadas exitosamente.'
          : 'Error al eliminar las categorías.',
    );
  }
}
