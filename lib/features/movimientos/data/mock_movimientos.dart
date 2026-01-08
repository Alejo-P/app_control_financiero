import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:flutter/material.dart';

final mockMovimientos = <Movimiento>[
  Movimiento(
    id: '1',
    title: 'Compra en supermercado',
    categoryID: 'alimentos',
    type: TipoMovimiento.gasto,
    ammount: 150.75,
    date: DateTime(2025, 12, 20),
    time: const TimeOfDay(hour: 14, minute: 30),
    note: 'Compra semanal de alimentos',
  ),
  Movimiento(
    id: '2',
    title: 'Pago de salario',
    categoryID: 'trabajo',
    type: TipoMovimiento.ingreso,
    ammount: 2500.00,
    date: DateTime(2025, 12, 29),
    time: const TimeOfDay(hour: 9, minute: 0),
    note: 'Salario mensual recibido',
  ),
  Movimiento(
    id: '3',
    title: 'Compra de entradas de cine',
    categoryID: 'entretenimiento',
    type: TipoMovimiento.gasto,
    ammount: 80.50,
    date: DateTime(2025, 12, 29),
    time: const TimeOfDay(hour: 16, minute: 15),
    note: 'Película con amigos',
  ),
  Movimiento(
    id: '4',
    title: 'Cena en restaurante',
    categoryID: 'alimentos',
    type: TipoMovimiento.gasto,
    ammount: 80.50,
    date: DateTime(2025, 12, 27),
    time: const TimeOfDay(hour: 20, minute: 15),
    note: 'Cena con amigos',
  ),
  Movimiento(
    id: '5',
    title: 'Pago de salario',
    categoryID: 'trabajo',
    type: TipoMovimiento.ingreso,
    ammount: 2500.00,
    date: DateTime(2026, 1, 29),
    time: const TimeOfDay(hour: 9, minute: 0),
    note: 'Salario mensual recibido',
  ),
];