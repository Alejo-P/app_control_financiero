import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/shared/widgets/category_dropdown.dart';
import 'package:control_financiero/features/shared/widgets/label_card.dart';
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
  IconData? iconoCategoriaSeleccionada;
  Color? colorCategoriaSeleccionada;
  int categoriaSeleccionada = -1;
  List<Categoria> categorias = [];

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
        'Error al obtener movimientos por categoría: ${e.toString()}',
        level: LogLevel.error,
        tag: 'MovimientoSearchPage',
        stackTrace: stackTrace,
      );

      AppSnackbar.error(
        context,
        'Ocurrió un error al obtener los movimientos para la categoría seleccionada. Por favor, intenta nuevamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Crear recordatorio')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: WidgetsContainer(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          LabelCard(
                            label: "Categoría",
                            iconData: iconoCategoriaSeleccionada,
                            iconColor: colorCategoriaSeleccionada,
                            textStyle: textTheme.bodyMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          CategoryDropdown(
                            categorias: categorias,
                            selectedValue: categoriaSeleccionada,
                            onChangeCategory: _onChangeCategoria,
                          ),
                        ],
                      ),
                      AmountInput(
                        controller: _amountController,
                        //isEditable: !isViewOnly,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El monto es obligatorio';
                          }
                          final amount = double.tryParse(
                            value.trim().replaceAll(',', '.'),
                          );
                          if (amount == null || amount <= 0) {
                            return 'Ingrese un monto válido';
                          }
                          return null;
                        },
                      ),
                      TextInputCard(
                        textController: _descriptionController,
                        placeholder: 'Descripción (opcional)',
                        iconData: Icons.description,
                        iconColor: Colors.grey,
                        maxLength: 200,
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
