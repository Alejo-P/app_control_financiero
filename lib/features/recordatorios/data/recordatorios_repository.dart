import 'package:control_financiero/features/recordatorios/data/recordatorios_local_datasource.dart';
import 'package:control_financiero/features/recordatorios/models/info_card_recordatorio.dart';

class RecordatoriosRepository {
  final RecordatoriosLocalDataSource localDataSource;

  RecordatoriosRepository(this.localDataSource);

  ///Obtiene la lista de todos los recordatorios.
  ///@return Una lista de objetos InfoCardRecordatorio.
  Future<List<InfoCardRecordatorio>> fetchAllRecordatorios() async {
    return await localDataSource.fetchAllRecordatorios();
  }
}
