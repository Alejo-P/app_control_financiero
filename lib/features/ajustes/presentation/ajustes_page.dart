import 'package:control_financiero/features/ajustes/widgets/backup_password_dialog.dart';
import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/services/backup_service.dart';
import 'package:control_financiero/core/utils/file_utils.dart';
import 'package:control_financiero/features/ajustes/widgets/setting_option_card.dart';
import 'package:control_financiero/features/categorias/presentation/categorias_page.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
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
      _appState.clearFloatingActionButton();
    });
  }

  void _toggleDarkMode(bool value) {
    _appState.setDarkMode(value);
  }

  void exportarDatosExcel() async {
    final appState = context.read<AppState>();

    final confirmed = await showConfirmDialog(
      context,
      title: 'Exportar datos',
      content: 'Se generará un archivo Excel en la carpeta que elijas.',
    );

    if (confirmed != true) return;
    if (!mounted) return;

    // 👇 Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await appState.exportarMovimientos();

    if (!mounted) return;

    Navigator.pop(context); // cerrar loading

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);
  }

  void exportarDatosBackup() async {
    final appState = context.read<AppState>();

    final password = await showDialog<String>(
      context: context,
      builder: (_) => const BackupPasswordDialog(creating: true),
    );
    if (password == null) return;

    if (!mounted) return;

    // 👇 Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await appState.createBackup(password);

    if (!mounted) return;

    Navigator.pop(context); // cerrar loading

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);
  }

  void restaurarDatosBackup() async {
    final appState = context.read<AppState>();

    final confirmed = await showConfirmDialog(
      context,
      title: 'Restaurar datos',
      content:
          'Se restaurarán tus datos desde un archivo de respaldo. Esto reemplazará tus datos actuales.',
    );

    if (confirmed != true) return;

    final pickedFile = await FileUtils.pickFiles(['json']);
    if (!mounted) return;
    if (pickedFile == null) {
      AppSnackbar.error(context, 'No se selecciono un archivo');
      return;
    }

    final validationError = await BackupService().validateBackupFile(
      pickedFile,
    );
    if (!mounted) return;
    if (validationError != null) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('No se puede abrir el respaldo'),
          content: Text(validationError),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;

    final password = await showDialog<String>(
      context: context,
      builder: (_) => const BackupPasswordDialog(creating: false),
    );
    if (password == null || !mounted) return;

    // 👇 Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Restaurar datos
    await appState.restoreFromBackup(password, pickedFile);

    if (!mounted) return;

    Navigator.pop(context); // cerrar loading

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);
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
                        onTap: exportarDatosExcel,
                      ),
                      SettingOptionCard(
                        title: 'Respaldar datos',
                        description: 'Crea una copia de seguridad de tus datos',
                        icon: Icons.backup_outlined,
                        iconColor: Colors.green,
                        onTap: exportarDatosBackup,
                      ),
                      SettingOptionCard(
                        title: 'Restaurar datos',
                        description:
                            'Restaura tus datos desde una copia de seguridad',
                        icon: Icons.restore_outlined,
                        iconColor: Colors.red,
                        onTap: restaurarDatosBackup,
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
                      SettingOptionCard(
                        title: 'Recordatorios',
                        description:
                            'Gestiona los recordatorios de tus movimientos',
                        icon: Icons.alarm_outlined,
                        iconColor: Colors.blue,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.recordatoriosRoute,
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
                            '${!isDarkMode ? 'Activa' : 'Desactiva'} el modo oscuro en la aplicación',
                        icon: isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        iconColor: isDarkMode ? Colors.yellow : Colors.blue,
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: _toggleDarkMode,
                        ),
                      ),
                      SettingOptionCard(
                        title: 'Notificaciones',
                        description:
                            'Configura las notificaciones de la aplicación',
                        icon: Icons.notifications_outlined,
                        iconColor: Colors.teal,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.notificationConfigRoute,
                        ),
                      ),
                      SettingOptionCard(
                        title: 'Sobre la aplicación',
                        description:
                            'Información sobre la aplicación y su versión',
                        icon: Icons.info_outline,
                        iconColor: Colors.grey,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.aboutRoute),
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
