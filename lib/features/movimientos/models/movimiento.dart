import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class Movimiento {
  final String id;
  final String title;
  final String categoryID;
  final TipoMovimiento type;
  final double ammount;
  final DateTime date;
  final TimeOfDay time;
  final String note;

  Movimiento({
    required this.id,
    required this.title,
    required this.categoryID,
    required this.type,
    required this.ammount,
    required this.date,
    required this.time,
    this.note = '',
  });

  // Factory constructor to create a Movimiento from JSON
  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'],
      title: map['title'],
      categoryID: map['categoryID'],
      type: map['type'] == 'ingreso'
          ? TipoMovimiento.ingreso
          : TipoMovimiento.gasto,
      ammount: map['ammount'],
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
      'id': id,
      'title': title,
      'categoryID': categoryID,
      'type': type == TipoMovimiento.ingreso ? 'ingreso' : 'gasto',
      'ammount': ammount,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'note': note,
    };
  }

  // Funtion for debugging purposes
  @override
  String toString() {
    return 'Movimiento{id: $id, title: $title, categoryID: $categoryID, type: $type, ammount: $ammount, date: $date, time: $time, note: $note}';
  }
}
