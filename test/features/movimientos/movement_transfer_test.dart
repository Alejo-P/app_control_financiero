import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/app_state_fakes.dart';

class SourceRepository extends FakeMovimientos {
  final Movimiento source;
  SourceRepository(this.source);
  @override
  Future<Movimiento?> fetchMovimientoById(int id) async => source;
}

class TransferState extends TestAppState {
  Movimiento? saved;
  bool? updated;
  TransferState(Movimiento source)
    : super(movimientos: SourceRepository(source));
  @override
  Future<int> agregarMovimiento(Movimiento movimiento) async {
    saved = movimiento;
    updated = false;
    return 99;
  }

  @override
  Future<int> actualizarMovimiento(Movimiento movimiento) async {
    saved = movimiento;
    updated = true;
    return movimiento.id!;
  }
}

void main() {
  final now = currentDateTime;
  final today = DateTime(now.year, now.month, now.day);
  final source = Movimiento(
    id: 1,
    title: 'Compra',
    categoryID: 7,
    amount: 42,
    date: today.subtract(const Duration(days: 2)),
    time: const TimeOfDay(hour: 10, minute: 30),
    note: 'Nota original',
  );

  for (final move in [false, true]) {
    test(
      '${move ? 'mover conserva ID' : 'copiar omite ID'} y conserva campos',
      () async {
        final state = TransferState(source);
        final result = await state.transferirMovimiento(1, today, move: move);
        expect(result.success, isTrue);
        expect(state.saved!.id, move ? 1 : null);
        expect(state.saved!.date, today);
        expect(state.saved!.title, source.title);
        expect(state.saved!.categoryID, source.categoryID);
        expect(state.saved!.amount, source.amount);
        expect(state.saved!.time, source.time);
        expect(state.saved!.note, source.note);
        expect(state.updated, move);
        expect(source.date, today.subtract(const Duration(days: 2)));
      },
    );
  }
  test('rechaza futuro y fechas anteriores al límite sin guardar', () async {
    final state = TransferState(source);
    for (final invalid in [
      today.add(const Duration(days: 1)),
      DateTime(now.year - 4),
    ]) {
      for (final move in [false, true]) {
        expect(
          (await state.transferirMovimiento(1, invalid, move: move)).success,
          isFalse,
        );
      }
    }
    expect(state.saved, isNull);
  });
}
