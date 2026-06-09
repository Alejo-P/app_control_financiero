import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/ajustes/widgets/item_card.dart';
import 'package:control_financiero/features/ajustes/widgets/section_title.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification.dart';
import 'package:control_financiero/features/notificaciones/models/movement_notification_config.dart';
import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:control_financiero/features/shared/widgets/number_input_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationConfigPage extends StatefulWidget {
  const NotificationConfigPage({super.key});

  @override
  State<NotificationConfigPage> createState() => _NotificationConfigPageState();
}

class _NotificationConfigPageState extends State<NotificationConfigPage> {
  final TextEditingController _customThresholdController =
      TextEditingController();
  bool _isCustomThresholdValid = false;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    _customThresholdController.addListener(() {
      _validateCustomThreshold(_customThresholdController.text);
    });
  }

  @override
  void dispose() {
    _customThresholdController.dispose();
    super.dispose();
  }

  void _validateCustomThreshold(String value) {
    final appState = context.read<AppState>();
    final thresholds = appState.budgetThresholds;
    final numValue = double.tryParse(value) ?? 0;
    final errorMessage = value.isEmpty
        ? ''
        : (numValue < 1 || numValue > 100)
        ? 'Ingrese un número válido entre 1 y 100'
        : thresholds.contains(numValue / 100)
        ? 'Este umbral ya existe'
        : '';
    setState(() {
      _isCustomThresholdValid =
          (numValue >= 1 && numValue <= 100) &&
          !thresholds.contains(numValue / 100);
      errorText = errorMessage;
    });
  }

  Future<void> _addCustomThreshold() async {
    final appState = context.read<AppState>();
    final numValue = double.tryParse(_customThresholdController.text);

    final budgetNotification = BudgetNotification(
      id: null, // El ID se asignará automáticamente en la base de datos
      categoryId: null, // Null para notificaciones globales
      threshold: numValue != null ? numValue / 100 : 0.0,
      isEnabledNotification: true,
      createdAt: DateTime.now(),
    );

    if (numValue != null && numValue >= 0 && numValue <= 100) {
      await appState.addOrUpdateBudgetNotification(budgetNotification);
      _customThresholdController.clear();

      if (mounted) {
        setState(() {
          _isCustomThresholdValid =
              false; // Deshabilitar el botón después de agregar
        });
        AppSnackbar.success(context, 'Umbral agregado exitosamente');
      }
    } else {
      AppSnackbar.error(context, 'Ingrese un número válido entre 1 y 100');
    }
  }

  Future<void> _updateCustomThreshold({
    int id = -1,
    bool? isEnabledNotification,
  }) async {
    final appState = context.read<AppState>();

    await appState.updateBudgetNotification(
      id: id,
      isEnabledNotification: isEnabledNotification,
    );
  }

  Future<void> _deleteThreshold(int id) async {
    final appState = context.read<AppState>();
    await appState.deleteBudgetNotification(id);

    if (mounted) {
      _validateCustomThreshold(_customThresholdController.text);
      AppSnackbar.success(context, 'Umbral eliminado exitosamente');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final budgetNotifications = appState.budgetNotifications;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de Notificaciones')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SectionTitle(
                    title: 'Movimientos',
                    icon: Icons.account_balance_wallet_outlined,
                  ),

                  ItemCard(
                    title: 'Creación de movimientos',
                    value:
                        appState
                            .getMovementNotificationConfigByType(
                              MovementNotificationConfig.createMovementKey,
                            )
                            ?.isEnabled ??
                        false,
                    onChanged: (value) {
                      appState.updateMovementNotificationConfig(
                        typeKey: MovementNotificationConfig.createMovementKey,
                        isEnabled: value,
                      );
                    },
                  ),

                  ItemCard(
                    title: 'Edición de movimientos',
                    value:
                        appState
                            .getMovementNotificationConfigByType(
                              MovementNotificationConfig.editMovementKey,
                            )
                            ?.isEnabled ??
                        false,
                    onChanged: (value) {
                      appState.updateMovementNotificationConfig(
                        typeKey: MovementNotificationConfig.editMovementKey,
                        isEnabled: value,
                      );
                    },
                  ),

                  ItemCard(
                    title: 'Eliminación de movimientos',
                    value:
                        appState
                            .getMovementNotificationConfigByType(
                              MovementNotificationConfig.deleteMovementKey,
                            )
                            ?.isEnabled ??
                        false,
                    onChanged: (value) {
                      appState.updateMovementNotificationConfig(
                        typeKey: MovementNotificationConfig.deleteMovementKey,
                        isEnabled: value,
                      );
                    },
                  ),

                  SectionTitle(
                    title: 'Presupuestos',
                    icon: Icons.pie_chart_outline,
                  ),

                  if (budgetNotifications.isNotEmpty)
                    ...budgetNotifications.map(
                      (notification) => ItemCard(
                        title:
                            'Notificar al ${int.tryParse((notification.threshold * 100).toStringAsFixed(0)) ?? 0}% del presupuesto',
                        value: notification.isEnabledNotification,
                        showDeleteButton: !notification.isDefault,
                        onChanged: (value) {
                          _updateCustomThreshold(
                            id: notification.id ?? -1,
                            isEnabledNotification: value,
                          );
                        },
                        onDelete: () {
                          _deleteThreshold(notification.id!);
                        },
                      ),
                    ),

                  Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Otro porcentaje'),
                          NumberInputCard(
                            textController: _customThresholdController,
                            placeholder: 'Porcentaje personalizado (0-100)',
                            iconData: Icons.percent_rounded,
                            iconColor: Colors.blue,
                            maxLength: 5,
                          ),
                          if (errorText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                errorText,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          CustomButton(
                            onTap: !_isCustomThresholdValid
                                ? null
                                : () {
                                    _addCustomThreshold();
                                  },
                            icon: Icons.add,
                            text: 'Agregar umbral personalizado',
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
