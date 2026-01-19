import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class Movimiento {
  final int? id;
  final String title;
  final int categoryID;
  final TipoMovimiento type;
  final double amount;
  final DateTime date;
  final TimeOfDay time;
  final String note;

  Movimiento({
    this.id,
    required this.title,
    required this.categoryID,
    required this.type,
    required this.amount,
    required this.date,
    required this.time,
    this.note = '',
  });

  Movimiento copyWith({
    int? id,
    String? title,
    int? categoryID,
    TipoMovimiento? type,
    double? amount,
    DateTime? date,
    TimeOfDay? time,
    String? note,
  }) {
    return Movimiento(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryID: categoryID ?? this.categoryID,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      time: time ?? this.time,
      note: note ?? this.note,
    );
  }

  // Factory constructor to create a Movimiento from JSON
  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'] != null ? map['id'] as int : null,
      title: map['title'],
      categoryID: map['category_id'],
      type: map['type'] == 'ingreso'
          ? TipoMovimiento.ingreso
          : TipoMovimiento.gasto,
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(map['time'].split(':')[0]),
        minute: int.parse(map['time'].split(':')[1]),
      ),
      note: map['note'],
    );
  }

  // Method to convert a Movimiento to JSON
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category_id': categoryID,
      'type': type == TipoMovimiento.ingreso ? 'ingreso' : 'gasto',
      'amount': amount,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'note': note,
    };
  }

  // Funtion for debugging purposes
  @override
  String toString() {
    return 'Movimiento{id: $id, title: $title, categoryID: $categoryID, type: $type, amount: $amount, date: $date, time: $time, note: $note}';
  }
}
