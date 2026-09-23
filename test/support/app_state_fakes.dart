import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/categorias/data/categorias_repository.dart';
import 'package:control_financiero/features/historial/data/historial_repository.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_repository.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_repository.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_repository.dart';
import 'package:control_financiero/features/recordatorios/data/recordatorios_repository.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_repository.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMovimientos extends Fake implements MovimientosRepository {}

class FakeCategorias extends Fake implements CategoriasRepository {}

class FakeHistorial extends Fake implements HistorialRepository {}

class FakeNotificaciones extends Fake implements NotificacionRepository {}

class FakePresupuestos extends Fake implements PresupuestosRepository {}

class FakeRecordatorios extends Fake implements RecordatoriosRepository {}

class FakeTipos extends Fake implements TipoCategoriaRepository {
  @override
  List<TipoCategoria> get tipoCategorias => [];
}

class TestAppState extends AppState {
  TestAppState({
    MovimientosRepository? movimientos,
    RecordatoriosRepository? reminders,
  }) : super(
         movimientos ?? FakeMovimientos(),
         FakeCategorias(),
         FakeTipos(),
         FakePresupuestos(),
         FakeHistorial(),
         FakeNotificaciones(),
         reminders ?? FakeRecordatorios(),
       );
}
