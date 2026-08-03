import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/recordatorios/models/detalle_recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio_form_args.dart';
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
  bool _isLoading = false; // Variable para controlar el estado de carga
  bool _loaded = false;
  bool isViewOnly =
      false; // Variable para controlar si el formulario es solo lectura
  String _action = '';
  int categoryId = -1;
  IconData? iconoCategoriaSeleccionada;
  Color? colorCategoriaSeleccionada;
  int categoriaSeleccionada = -1;
  List<Categoria> categorias = [];
  DateTime fechaRecordatorio = currentDateTime;
  Recurrencia recurrenciaSeleccionada = Recurrencia.ninguno;
  DetalleRecordatorio? _detalleRecordatorio;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
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
          : '';
      _titleController.text = result.title;
      _descriptionController.text = result.description;
      categoriaSeleccionada = result.categoryId;
      fechaRecordatorio = result.scheduledAt;
      iconoCategoriaSeleccionada = result.categoryIcon;
      colorCategoriaSeleccionada = result.categoryColor;
      recurrenciaSeleccionada = Recurrencia.values.firstWhere(
        (r) => r.name == result.recurrency,
        orElse: () => Recurrencia.ninguno,
      );
    }

    if (!mounted) return;

    setState(() {
      _detalleRecordatorio = result;
      _isLoading = false;
    });
    //_checkEnableSaveButton();
  }

  Future<void> _selectDate(BuildContext context) async {
    final currentDay = currentDateTime;
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: 'Selecciona la fecha del recordatorio',
      initialDate: fechaRecordatorio,
      firstDate: DateTime(currentDay.year - 3),
      lastDate: DateTime(currentDay.year, currentDay.month, currentDay.day),
    );

    if (picked != null && picked != fechaRecordatorio) {
      setState(() {
        fechaRecordatorio = picked;
      });
      // _checkEnableSaveButton();
    }
  }

  Future<void> _saveRecordatorio() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = context.read<AppState>();

    setState(() {
      _isLoading = true;
      _action = "Guardando";
    });

    final recordatorio = Recordatorio(
      id: _detalleRecordatorio?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      categoryId: categoriaSeleccionada,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      scheduledAt: fechaRecordatorio,
      recurrencia: recurrenciaSeleccionada,
    );

    try {
      await appState.actualizarRecordatorio(recordatorio);
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
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear recordatorio')),
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
                                        if (amount == null || amount <= 0) {
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
                                  onTap: () =>
                                      isViewOnly ? null : _selectDate(context),
                                  borderRadius: BorderRadius.circular(12),
                                  child: DetailCategoryCard(
                                    categoryName: 'Fecha',
                                    categoryIcon: Icons.calendar_today,
                                    iconColor: Colors.purple,
                                    currentValue: formatDate(fechaRecordatorio),
                                    showArrow: !isViewOnly,
                                  ),
                                ),
                                LabeledFormField(
                                  label: "Recurrencia",
                                  icon: Icon(Icons.repeat, color: Colors.teal),
                                  child: CustomDropdown<Recurrencia>(
                                    selectedItem: recurrenciaSeleccionada,
                                    items: Recurrencia.values,
                                    itemLabelBuilder: (Recurrencia value) =>
                                        value.name,
                                    onChanged: (newValue) {
                                      setState(() {
                                        recurrenciaSeleccionada = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            CustomButton(
                              text: 'Guardar',
                              icon: Icons.save,
                              width: WidgetWidth.fullWidth,
                              onTap: _isLoading
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
    );
  }
}
