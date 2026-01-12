import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/ajustes/widgets/setting_option_card.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  late AppState _appState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appState = context.read<AppState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState.clearAppBarActions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetsContainer(
            title: 'Gestion de datos'.toUpperCase(),
            description: 'Opciones para respaldar y restaurar tus datos.',
            children: [
              SettingOptionCard(
                title: 'Exportar datos a Excel',
                description: 'Exporta tus movimientos en un archivo .xlsx',
                icon: Icons.table_view_outlined,
                iconColor: Colors.orange,
                onTap: () {
                  // Lógica para exportar datos a Excel
                  debugPrint('Exportar datos a Excel');
                },
              ),
              SettingOptionCard(
                title: 'Respaldar datos',
                icon: Icons.backup,
                iconColor: Colors.blue,
              ),
              SettingOptionCard(
                title: 'Restaurar datos',
                icon: Icons.restore,
                iconColor: Colors.green,
              ),
            ],
          ),
          // Aquí puedes agregar más widgets para los ajustes
        ],
      ),
    );
  }
}
