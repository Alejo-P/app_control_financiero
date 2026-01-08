import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:flutter/material.dart';


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
  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      title: json['title'],
      categoryID: json['categoryID'],
      type: json['type'] == 'ingreso'
          ? TipoMovimiento.ingreso
          : TipoMovimiento.gasto,
      ammount: json['ammount'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: json['time']['hour'],
        minute: json['time']['minute'],
      ),
      note: json['note'],
    );
  }

  // Method to convert a Movimiento to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categoryID': categoryID,
      'type': type == TipoMovimiento.ingreso ? 'ingreso' : 'gasto',
      'ammount': ammount,
      'date': date.toIso8601String(),
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'note': note,
    };
  }

  // Funtion for debugging purposes
  @override
  String toString() {
    return 'Movimiento{id: $id, title: $title, categoryID: $categoryID, type: $type, ammount: $ammount, date: $date, time: $time, note: $note}';
  }
}
