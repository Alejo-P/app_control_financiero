import 'package:control_financiero/core/tutorials/tutorial_host.dart';
import 'package:control_financiero/core/tutorials/tutorial_step.dart';
import 'package:control_financiero/features/ajustes/widgets/backup_password_dialog.dart';
import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/services/backup_service.dart';
import 'package:control_financiero/core/utils/file_utils.dart';
import 'package:control_financiero/features/ajustes/widgets/setting_option_card.dart';
import 'package:control_financiero/features/categorias/presentation/categorias_page.dart';
import 'package:control_financiero/features/shared/widgets/dialogs.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/features/ajustes/widgets/error_report_dialog.dart';

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  late AppState _appState;
  bool _controlsConfigured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appState = context.read<AppState>();
    if (_controlsConfigured) return;
    _controlsConfigured = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _appState.currentTab != 3) return;
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
    showLoadingDialog(context, 'Exportando datos a Excel...');

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
    showLoadingDialog(
      context,
      'Creando respaldo...\n'
      'Puede tardar unos segundos dependiendo de la cantidad de datos.',
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
          title: Text(
            'No se puede abrir el respaldo',
            style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
              color: Theme.of(dialogContext).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
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
    showLoadingDialog(
      context,
      'Restaurando respaldo...\n'
      'Espere un momento',
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

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
                      TutorialTarget(
                        step: TutorialStep.excel,
                        child: SettingOptionCard(
                          title: 'Exportar datos a Excel',
                          description:
                              'Exporta tus movimientos en un archivo .xlsx',
                          icon: Icons.table_view_outlined,
                          iconColor: Colors.orange,
                          onTap: exportarDatosExcel,
                        ),
                      ),
                      TutorialTarget(
                        step: TutorialStep.backup,
                        child: SettingOptionCard(
                          title: 'Respaldar datos',
                          description:
                              'Crea una copia de seguridad de tus datos',
                          icon: Icons.backup_outlined,
                          iconColor: Colors.green,
                          onTap: exportarDatosBackup,
                        ),
                      ),
                      TutorialTarget(
                        step: TutorialStep.restore,
                        child: SettingOptionCard(
                          title: 'Restaurar datos',
                          description:
                              'Restaura tus datos desde una copia de seguridad',
                          icon: Icons.restore_outlined,
                          iconColor: Colors.red,
                          onTap: restaurarDatosBackup,
                        ),
                      ),
                    ],
                  ),
                  WidgetsContainer(
                    title: 'Mas elementos',
                    description: 'Gestiona categorias y otros elementos.',
                    children: [
                      TutorialTarget(
                        step: TutorialStep.categories,
                        child: SettingOptionCard(
                          title: 'Categorias',
                          description:
                              'Gestiona las categorias de tus movimientos',
                          icon: Icons.category_outlined,
                          iconColor: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoriasPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      TutorialTarget(
                        step: TutorialStep.reminders,
                        child: SettingOptionCard(
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
                      ),
                    ],
                  ),
                  WidgetsContainer(
                    title: 'Ajustes de la app',
                    description: 'Configura las preferencias de la aplicación.',
                    children: [
                      SettingOptionCard(
                        title: 'Ver tutoriales',
                        description: 'Repite las guías de las cuatro secciones',
                        icon: Icons.play_arrow_rounded,
                        iconColor: Colors.orange,
                        onTap: () async {
                          final reset = context
                              .read<TutorialCoordinator?>()
                              ?.reset;
                          if (reset != null) await reset();
                        },
                      ),
                      TutorialTarget(
                        step: TutorialStep.darkMode,
                        child: SettingOptionCard(
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
                      ),
                      TutorialTarget(
                        step: TutorialStep.notificationSettings,
                        child: SettingOptionCard(
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
                      ),
                      TutorialTarget(
                        step: TutorialStep.about,
                        child: SettingOptionCard(
                          title: 'Sobre la aplicación',
                          description:
                              'Información sobre la aplicación y su versión',
                          icon: Icons.info_outline,
                          iconColor: Colors.grey,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.aboutRoute,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        final sent = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const ErrorReportDialog(),
                        );
                        if (sent == true && context.mounted) {
                          AppSnackbar.success(
                            context,
                            'Reporte enviado para revisión.',
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(
                            Icons.bug_report_outlined,
                            color: colorScheme.primary,
                          ),
                          Flexible(
                            child: Text(
                              'Notificar un error',
                              textAlign: TextAlign.center,
                              style: textTheme.displaySmall?.copyWith(
                                color: colorScheme.primary,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
