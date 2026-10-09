import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/presupuestos/models/category_card_info.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import '../../support/app_state_fakes.dart';

class FailingMovimientos extends FakeMovimientos {
  final Object failure = StateError('nota privada, monto 12345');

  @override
  Future<OperationResult<int>> addMovimiento(Movimiento movimiento) async {
    throw failure;
  }
}

class FailingPresupuestos extends FakePresupuestos {
  final Object failure = StateError('monto privado 98765');

  @override
  Future<OperationResult<CategoryCardInfo?>> addPresupuesto(
    Presupuesto presupuesto,
  ) async {
    throw failure;
  }
}

class BrokenStackTrace implements StackTrace {
  @override
  String toString() => throw StateError('trace unavailable');
}

class FailedDatabase extends Fake implements DatabaseException {
  @override
  int? getResultCode() => 2067;

  @override
  String toString() =>
      'SQL INSERT INTO movimientos VALUES (12345, nota privada)';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('includes the precise exception message without its payload', () {
    expect(
      AppLogger.errorDetail(
        Exception('Error de prueba al guardar el movimiento'),
      ),
      'Exception: Error de prueba al guardar el movimiento',
    );
    expect(
      AppLogger.errorDetail(
        FormatException('Fecha inválida', 'nota privada 12345'),
      ),
      'Fecha inválida',
    );
    expect(
      AppLogger.errorDetail(
        PlatformException(
          code: 'denied',
          message: 'Acceso denegado',
          details: {'password': 'secreto'},
        ),
      ),
      'Acceso denegado',
    );
    expect(
      AppLogger.errorDetail(ArgumentError.value('clave privada', 'password')),
      'Argumento inválido',
    );
  });

  test('redacts sensitive message fields and bounds message size', () {
    final detail = AppLogger.errorDetail(
      Exception(
        'Falló; password=secreto; token=abc; monto 12345; note=privada; https://host/path?key=abc; persona@example.com',
      ),
    );
    for (final value in ['secreto', 'abc', '12345', 'privada', 'example.com']) {
      expect(detail, isNot(contains(value)));
    }
    expect(detail, contains('Falló'));
    expect(AppLogger.errorDetail(Exception('x' * 1000)).length, 501);
  });

  test('SQLite keeps its specific result code without SQL or arguments', () {
    expect(
      AppLogger.errorDetail(FailedDatabase()),
      'Restricción de integridad incumplida (sqlite_code=2067)',
    );
  });

  test(
    'budget failure records its operation without exposing the amount',
    () async {
      final repository = FailingPresupuestos();
      final state = AppState(
        FakeMovimientos(),
        FakeCategorias(),
        FakeTipos(),
        repository,
        FakeHistorial(),
        FakeNotificaciones(),
        FakeRecordatorios(),
      );
      final entries = <String>[];
      final previousPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) entries.add(message);
      };
      try {
        await expectLater(
          state.agregarPresupuesto(
            Presupuesto(
              categoryId: 1,
              amount: 98765,
              date: DateTime(2026, 10, 1),
            ),
          ),
          throwsA(same(repository.failure)),
        );
        final log = entries.join('\n');
        expect(log, contains('AppState.agregarPresupuesto (StateError)'));
        expect(log, isNot(contains('privado')));
        expect(log, isNot(contains('98765')));
      } finally {
        debugPrint = previousPrint;
        state.dispose();
      }
    },
  );

  test('diagnostic failure never escapes to the application', () async {
    await expectLater(
      AppLogger.log('Fallo controlado', stackTrace: BrokenStackTrace()),
      completes,
    );
  });

  test('error summaries omit messages and platform details', () {
    expect(AppLogger.errorSummary(StateError('nota privada')), 'StateError');
    expect(
      AppLogger.errorSummary(
        PlatformException(
          code: 'permission_denied',
          message: 'contraseña privada',
          details: {'amount': 12345},
        ),
      ),
      'PlatformException, code=permission_denied',
    );
    expect(
      AppLogger.errorSummary(PlatformException(code: 'ruta/usuario privado')),
      'PlatformException',
    );
  });

  test(
    'movement failure is logged and the same error reaches the caller',
    () async {
      final repository = FailingMovimientos();
      final state = TestAppState(movimientos: repository);
      final entries = <String>[];
      final previousPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) entries.add(message);
      };
      try {
        await expectLater(
          state.agregarMovimiento(
            Movimiento(
              title: 'título privado',
              categoryID: 1,
              amount: 12345,
              date: DateTime(2026, 10, 9),
              time: const TimeOfDay(hour: 12, minute: 0),
              note: 'nota privada',
            ),
          ),
          throwsA(same(repository.failure)),
        );
        final log = entries.join('\n');
        expect(log, contains('AppState.agregarMovimiento (StateError)'));
        expect(log, contains('package:control_financiero/app/app_state.dart'));
        expect(log, isNot(contains('privad')));
        expect(log, isNot(contains('12345')));
      } finally {
        debugPrint = previousPrint;
        state.dispose();
      }
    },
  );
}
