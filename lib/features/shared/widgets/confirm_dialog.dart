import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String titleModal,
  required String title,
  required String category,
  required TipoMovimiento tipoMovimiento,
  required String amount,
  required DateTime date,
  String? note,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // obliga a elegir
    builder: (context) {
      return AlertDialog(
        title: Text(
          titleModal,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título: $title'),
            Text('Monto: \$$amount'),
            Text('Tipo: ${tipoMovimiento == TipoMovimiento.gasto ? 'Gasto' : 'Ingreso'}'),
            Text('Categoría: $category'),
            Text('Fecha: ${formatDate(date)}'),
            if (note != null && note.isNotEmpty) Text('Nota: ${note.trim()}'),
          ],
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
}
