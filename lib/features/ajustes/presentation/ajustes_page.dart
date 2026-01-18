import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/ajustes/widgets/setting_option_card.dart';
import 'package:control_financiero/features/categorias/presentation/categorias_page.dart';
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

  void _toggleDarkMode(bool value) {
    setState(() {
      _appState.setDarkMode(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDarkMode = appState.isDarkMode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  WidgetsContainer(
                    title: 'Gestion de datos',
                    description:
                        'Opciones para respaldar y restaurar tus datos.',
                    children: [
                      SettingOptionCard(
                        title: 'Exportar datos a Excel',
                        description:
                            'Exporta tus movimientos en un archivo .xlsx',
                        icon: Icons.table_view_outlined,
                        iconColor: Colors.orange,
                        onTap: () {
                          // Lógica para exportar datos a Excel
                          debugPrint('Exportar datos a Excel');
                        },
                      ),
                      SettingOptionCard(
                        title: 'Respaldar datos',
                        description: 'Crea una copia de seguridad de tus datos',
                        icon: Icons.backup_outlined,
                        iconColor: Colors.green,
                        onTap: () {
                          // Lógica para respaldar datos
                          debugPrint('Respaldar datos');
                        },
                      ),
                      SettingOptionCard(
                        title: 'Restaurar datos',
                        description:
                            'Restaura tus datos desde una copia de seguridad',
                        icon: Icons.restore_outlined,
                        iconColor: Colors.red,
                        onTap: () {
                          // Lógica para restaurar datos
                          debugPrint('Restaurar datos');
                        },
                      ),
                    ],
                  ),
                  WidgetsContainer(
                    title: 'Mas elementos',
                    description: 'Gestiona categorias y otros elementos.',
                    children: [
                      SettingOptionCard(
                        title: 'Categorias',
                        description:
                            'Gestiona las categorias de tus movimientos',
                        icon: Icons.category_outlined,
                        iconColor: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CategoriasPage()),
                          );
                        },
                      ),
                    ],
                  ),
                  WidgetsContainer(
                    title: 'Ajustes de la app',
                    description: 'Configura las preferencias de la aplicación.',
                    children: [
                      SettingOptionCard(
                        title: 'Modo oscuro',
                        description:
                            'Activa o desactiva el modo oscuro en la aplicación',
                        icon: isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        iconColor: isDarkMode ? Colors.yellow : Colors.blue,
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: _toggleDarkMode,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
