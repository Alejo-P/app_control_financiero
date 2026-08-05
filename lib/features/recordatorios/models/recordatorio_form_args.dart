import 'package:control_financiero/features/categorias/models/categoria.dart';

class RecordatorioFormArgs {
  final int id;
  final String? title;
  final String? description;
  final double? amount;
  final Categoria? category;
  final DateTime? scheduledAt;

  RecordatorioFormArgs({
    required this.id,
    this.title,
    this.description,
    this.amount,
    this.category,
    this.scheduledAt,
  });
}
