import 'package:flutter/material.dart';

class ExtraDataTable extends StatelessWidget {
  final Map<String, dynamic> data;

  const ExtraDataTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade300),
      ),
      children: data.entries.map((entry) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                entry.key,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                _formatValue(entry.value),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';

    // Si es número (ej: monto)
    if (value is num) {
      return value.toString();
    }

    // Si es String (incluye fechas ya serializadas)
    if (value is String) {
      return value;
    }

    return value.toString();
  }
}