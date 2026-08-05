import 'package:control_financiero/core/database/db_tables.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Movimiento {
  final int? id;
  final String title;
  final int categoryID;
  final double amount;
  final DateTime date;
  final TimeOfDay time;
  final String note;

  Movimiento({
    this.id,
    required this.title,
    required this.categoryID,
    required this.amount,
    required this.date,
    required this.time,
    this.note = '',
  });

  Movimiento copyWith({
    int? id,
    String? title,
    int? categoryID,
    double? amount,
    DateTime? date,
    TimeOfDay? time,
    String? note,
  }) {
    return Movimiento(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryID: categoryID ?? this.categoryID,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      time: time ?? this.time,
      note: note ?? this.note,
    );
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map[MovimientosTable.id] != null
          ? map[MovimientosTable.id] as int
          : null,
      title: map[MovimientosTable.title] as String,
      categoryID: map[MovimientosTable.categoryId] as int,
      amount: (map[MovimientosTable.amount] as num).toDouble(),
      date: DateTime.parse(map[MovimientosTable.date] as String),
      time: TimeOfDay(
        hour: int.parse((map[MovimientosTable.time] as String).split(':')[0]),
        minute: int.parse((map[MovimientosTable.time] as String).split(':')[1]),
      ),
      note: map[MovimientosTable.note] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      MovimientosTable.id: id,
      MovimientosTable.title: title,
      MovimientosTable.categoryId: categoryID,
      MovimientosTable.amount: amount,
      MovimientosTable.date: DateFormat('yyyy-MM-dd').format(date),
      MovimientosTable.time:
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      MovimientosTable.note: note,
    };
  }

  @override
  String toString() {
    return 'Movimiento{id: $id, title: $title, categoryID: $categoryID, amount: $amount, date: $date, time: $time, note: $note}';
  }
}
