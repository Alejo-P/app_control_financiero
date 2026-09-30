import 'package:control_financiero/core/utils/record_date_limits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('movimientos incluyen hoy y exactamente tres años atrás', () {
    final limits = RecordDateLimits.movimientos(now: DateTime(2026, 9, 29, 23));
    expect(limits.contains(DateTime(2023, 9, 29)), isTrue);
    expect(limits.contains(DateTime(2023, 9, 28)), isFalse);
    expect(limits.contains(DateTime(2026, 9, 29, 23, 59)), isTrue);
    expect(limits.contains(DateTime(2026, 9, 30)), isFalse);
  });
  test('el límite de febrero se ajusta al último día válido', () {
    final limits = RecordDateLimits.movimientos(now: DateTime(2024, 2, 29));
    expect(limits.first, DateTime(2021, 2, 28));
  });
  test('presupuestos incluyen los meses a doce meses de distancia', () {
    final limits = RecordDateLimits.presupuestos(now: DateTime(2026, 9, 29));
    expect(limits.contains(DateTime(2025, 9)), isTrue);
    expect(limits.contains(DateTime(2027, 9)), isTrue);
    expect(limits.contains(DateTime(2025, 8)), isFalse);
    expect(limits.contains(DateTime(2027, 10)), isFalse);
  });
}
