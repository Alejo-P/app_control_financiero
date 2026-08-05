import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/recordatorio_constants.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/time_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/recordatorios/models/detalle_recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio_form_args.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:control_financiero/features/shared/widgets/custom_dropdown.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
import 'package:control_financiero/features/shared/widgets/category_dropdown.dart';
import 'package:control_financiero/features/shared/widgets/detail_category_card.dart';
import 'package:control_financiero/features/shared/widgets/labeled_form_field.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:control_financiero/features/shared/widgets/text_input_card.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecordatorioFormPage extends StatefulWidget {
  const RecordatorioFormPage({super.key});

  @override
  State<RecordatorioFormPage> createState() => _RecordatorioFormPageState();
}

class _RecordatorioFormPageState extends State<RecordatorioFormPage> {
  DetalleRecordatorio? detalleRecordatorio;
  RecordatorioFormMode formMode = RecordatorioFormMode.create;
  bool _isLoading = false; // Variable para controlar el estado de carga
  bool _enableSaveButton =
      false; // Variable para controlar el estado del botón Guardar
  bool _loaded = false;
  bool isViewOnly =
      false; // Variable para controlar si el formulario es solo lectura
  String _action = '';
  String nombreCategoria = '';
  IconData? iconoCategoriaSeleccionada;
  Color? colorCategoriaSeleccionada;
  int categoriaSeleccionada = -1;
  List<Categoria> categorias = [];
  DateTime fechaRecordatorio = currentDateTime;
  Recurrencia recurrenciaSeleccionada = Recurrencia.ninguno;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController(text: '0.0');
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final appState = context.read<AppState>();
    final categorias = appState.categorias;
    setState(() {
      this.categorias = categorias;
    });

    if (categorias.isNotEmpty) {
      categoriaSeleccionada = categorias.first.id!;
      iconoCategoriaSeleccionada = categorias.first.iconData;
      colorCategoriaSeleccionada = categorias.first.iconColor;
    }

    _titleController.addListener(_checkEnableSaveButton);
    _amountController.addListener(_checkEnableSaveButton);
    _descriptionController.addListener(_checkEnableSaveButton);
  }

  @override
  void dispose() {
    // Limpiar los controladores al desechar el widget
    _amountController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final args =
        ModalRoute.of(context)!.settings.arguments as RecordatorioFormArgs;
    final id = args.id;

    _load(id);

    _loaded = true;
  }

  Future<void> _load(int id) async {
    final appState = context.read<AppState>();

    setState(() {
      _isLoading = true;
      _action = "Cargando";
    });

    final result = await appState.getRecordatorioById(id);
    if (result != null) {
      _amountController.text = result.amount != 0.0
          ? result.amount.toString()
          : '0.0';
      _titleController.text = result.title;
      _descriptionController.text = result.description;
      categoriaSeleccionada = result.categoryId;
      fechaRecordatorio = result.scheduledAt;
      nombreCategoria = result.categoryName;
      iconoCategoriaSeleccionada = result.categoryIcon;
      colorCategoriaSeleccionada = result.categoryColor;
      recurrenciaSeleccionada = Recurrencia.values.firstWhere(
        (r) => r.name == result.recurrency,
        orElse: () => Recurrencia.ninguno,
      );
    }

    if (!mounted) return;

    setState(() {
      detalleRecordatorio = result;
      _isLoading = false;

      formMode = id == -1
          ? RecordatorioFormMode.create
          : RecordatorioFormMode.edit;
    });
    //_checkEnableSaveButton();
  }

  Future<void> _selectDate(BuildContext context) async {
    final currentDay = currentDateTime;
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: 'Selecciona la fecha del recordatorio',
      initialDate: fechaRecordatorio,
      firstDate: fechaRecordatorio.isBefore(currentDay)
          ? fechaRecordatorio
          : currentDay,
      lastDate: currentDay.add(
        const Duration(days: 365 * 5),
      ), // 5 años en el futuro
    );

    if (!mounted) return;

    if (picked == null || picked == fechaRecordatorio) return;
    final isValidDate = _checkValidDateTime(picked);

    if (!isValidDate) {
      AppSnackbar.error(
        // ignore: use_build_context_synchronously
        context,
        'La fecha seleccionada no puede ser anterior a la actual.',
      );
      return;
    }

    setState(() {
      fechaRecordatorio = DateTime(
        picked.year,
        picked.month,
        picked.day,
        fechaRecordatorio.hour,
        fechaRecordatorio.minute,
      );
    });
    _checkEnableSaveButton();
  }

  bool _checkValidDateTime(DateTime dateTime) {
    final currentDay = currentDateTime;
    return dateTime.isAfter(currentDay) || isSameDay(dateTime, currentDay);
  }

  Future<void> _selectTime(BuildContext context) async {
    if (isPastDate(fechaRecordatorio)) {
      AppSnackbar.error(
        context,
        'No se puede seleccionar una hora para un recordatorio vencido.',
      );
      return;
    }

    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fechaRecordatorio),
      helpText: 'Selecciona la hora del recordatorio',
    );

    if (timePicked == null) return;
    final isValidTime = _checkValidTime(timePicked);

    if (!isValidTime) {
      AppSnackbar.error(
        // ignore: use_build_context_synchronously
        context,
        'La hora seleccionada no puede ser anterior a la actual.',
      );
      return;
    }

    setState(() {
      fechaRecordatorio = DateTime(
        fechaRecordatorio.year,
        fechaRecordatorio.month,
        fechaRecordatorio.day,
        timePicked.hour,
        timePicked.minute,
      );
    });
    _checkEnableSaveButton();
  }

  bool _checkValidTime(TimeOfDay time) {
    final now = currentDateTime;

    if (isPastDate(fechaRecordatorio, now)) return false;
    if (!isSameDay(fechaRecordatorio, now)) return true;

    final currentTime = TimeOfDay.fromDateTime(now);
    return !time.isBefore(currentTime);
  }

  Future<void> _saveRecordatorio() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final isValidDate = _checkValidDateTime(fechaRecordatorio);
    if (!isValidDate) {
      AppSnackbar.error(
        // ignore: use_build_context_synchronously
        context,
        'La fecha seleccionada no puede ser anterior a la actual.',
      );
      return;
    }

    final timeOfDay = getTimeFromDateTime(fechaRecordatorio);
    final isValidTime = _checkValidTime(timeOfDay);
    if (!isValidTime) {
      AppSnackbar.error(
        // ignore: use_build_context_synchronously
        context,
        'La hora seleccionada no puede ser anterior a la actual.',
      );
      return;
    }

    final appState = context.read<AppState>();

    setState(() {
      _isLoading = true;
      _action = "Guardando";
    });

    final recordatorio = Recordatorio(
      id: detalleRecordatorio?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      categoryId: categoriaSeleccionada,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      scheduledAt: fechaRecordatorio,
      recurrencia: recurrenciaSeleccionada,
    );

    try {
      final isUpdateRecordatorio = formMode == RecordatorioFormMode.edit;
      if (isUpdateRecordatorio) {
        await appState.actualizarRecordatorio(recordatorio);
      } else {
        await appState.agregarRecordatorio(recordatorio);
      }
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _action = '';
      });

      AppSnackbar.success(context, 'Recordatorio guardado exitosamente');
      Navigator.pop(context);
    } catch (e, stackTrace) {
      if (!mounted) return;

      AppLogger.log(
        'Error al guardar recordatorio: ${e.toString()}',
        level: LogLevel.error,
        tag: 'RecordatorioFormPage',
        stackTrace: stackTrace,
      );

      AppSnackbar.error(
        context,
        'Ocurrió un error al guardar el recordatorio. Por favor, inténtalo de nuevo.',
      );
    }
  }

  Future<void> _onChangeCategoria(int categoriaId) async {
    if (categoriaSeleccionada == categoriaId) return;

    try {
      final categoria = categorias.firstWhere((cat) => cat.id == categoriaId);

      setState(() {
        categoriaSeleccionada = categoriaId;
        iconoCategoriaSeleccionada = categoria.iconData;
        colorCategoriaSeleccionada = categoria.iconColor;
        nombreCategoria = categoria.name;
      });

      _checkEnableSaveButton();
    } on Exception catch (e, stackTrace) {
      if (!mounted) return;

      AppLogger.log(
        'Error al obtener categorías: ${e.toString()}',
        level: LogLevel.error,
        tag: 'RecordatorioFormPage',
        stackTrace: stackTrace,
      );

      AppSnackbar.error(
        context,
        'Ocurrió un error al obtener la categoría seleccionada. Por favor, inténtalo de nuevo.',
      );
    }
  }

  bool _checkForChanges() {
    final current = DetalleRecordatorio(
      id: detalleRecordatorio?.id ?? -1,
      title: _titleController.text,
      description: _descriptionController.text,
      isEnabled: detalleRecordatorio?.isEnabled ?? true,
      scheduledAt: fechaRecordatorio,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      recurrency: recurrenciaSeleccionada.name,
      categoryId: categoriaSeleccionada,
      categoryName: nombreCategoria,
      categoryIcon: iconoCategoriaSeleccionada!,
      categoryColor: colorCategoriaSeleccionada!,
    );

    final original =
        detalleRecordatorio ??
        DetalleRecordatorio(
          id: -1,
          title: '',
          description: '',
          isEnabled: true,
          scheduledAt: fechaRecordatorio,
          amount: 0.0,
          recurrency: Recurrencia.ninguno.name,
          categoryId: categoriaSeleccionada,
          categoryName: nombreCategoria,
          categoryIcon: iconoCategoriaSeleccionada!,
          categoryColor: colorCategoriaSeleccionada!,
        );

    return current != original;
  }

  void _checkEnableSaveButton() {
    final hasChanges = _checkForChanges();
    final isFormValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _enableSaveButton = hasChanges && isFormValid;
    });
  }

  Future<bool> _onWillPop() async {
    final hasChanges = _checkForChanges();
    if (!hasChanges) return true;

    final confirm = await showConfirmDialog(
      context,
      title: 'Salir sin guardar',
      content:
          'Hay cambios sin guardar. ¿Estás seguro de que deseas salir sin guardar?',
    );

    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            formMode == RecordatorioFormMode.create
                ? 'Crear recordatorio'
                : 'Editar recordatorio',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: _isLoading
              ? LoadingScreen(message: _action)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              WidgetsContainer(
                                title: 'Detalles del recordatorio',
                                padding: EdgeInsets.all(12),
                                showDivider: false,
                                children: [
                                  TextInputCard(
                                    textController: _titleController,
                                    placeholder: 'Nombre del recordatorio',
                                    iconData: Icons.title,
                                    iconColor: Colors.blue,
                                    maxLength: 50,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingrese un nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  LabeledFormField(
                                    label: "Categoría",
                                    icon: Icon(
                                      iconoCategoriaSeleccionada ??
                                          Icons.category,
                                      color:
                                          colorCategoriaSeleccionada ??
                                          Colors.blue,
                                    ),
                                    child: CategoryDropdown(
                                      categorias: categorias,
                                      selectedValue: categoriaSeleccionada,
                                      onChangeCategory: _onChangeCategoria,
                                    ),
                                  ),
                                  LabeledFormField(
                                    label: "Monto",
                                    icon: Icon(
                                      Icons.attach_money,
                                      color: Colors.green,
                                    ),
                                    child: Expanded(
                                      child: AmountInput(
                                        controller: _amountController,
                                        showLabel: false,
                                        textAlign: TextAlign.center,
                                        position: MainAxisAlignment.end,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor ingrese un monto';
                                          }
                                          final amount = double.tryParse(value);
                                          if (amount == null || amount < 0) {
                                            return 'Por favor ingrese un monto válido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  TextInputCard(
                                    textController: _descriptionController,
                                    placeholder: 'Descripción (opcional)',
                                    iconData: Icons.description,
                                    iconColor: Colors.grey,
                                    maxLength: 200,
                                  ),
                                  InkWell(
                                    onTap: () => isViewOnly
                                        ? null
                                        : _selectDate(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: DetailCategoryCard(
                                      categoryName: 'Fecha',
                                      categoryIcon: Icons.calendar_today,
                                      iconColor: Colors.purple,
                                      currentValue: formatDate(
                                        fechaRecordatorio,
                                      ),
                                      showArrow: !isViewOnly,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => isViewOnly
                                        ? null
                                        : _selectTime(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: DetailCategoryCard(
                                      categoryName: 'Hora',
                                      categoryIcon: Icons.access_time,
                                      iconColor: Colors.orange,
                                      currentValue: formatTimeFromDateTime(
                                        context,
                                        fechaRecordatorio,
                                      ),
                                      showArrow: !isViewOnly,
                                    ),
                                  ),
                                  LabeledFormField(
                                    label: "Recurrencia",
                                    icon: Icon(
                                      Icons.repeat,
                                      color: Colors.teal,
                                    ),
                                    child: CustomDropdown<Recurrencia>(
                                      selectedItem: recurrenciaSeleccionada,
                                      items: Recurrencia.values,
                                      itemLabelBuilder: (Recurrencia value) =>
                                          value.name,
                                      onChanged: (newValue) {
                                        setState(() {
                                          recurrenciaSeleccionada = newValue!;
                                        });
                                        _checkEnableSaveButton();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              CustomButton(
                                text: formMode == RecordatorioFormMode.create
                                    ? 'Guardar'
                                    : 'Actualizar',
                                icon: Icons.save,
                                width: WidgetWidth.fullWidth,
                                onTap: (_isLoading || !_enableSaveButton)
                                    ? null
                                    : _saveRecordatorio,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
