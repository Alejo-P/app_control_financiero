import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/categoria_constants.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/categorias/models/detalle_categoria.dart';
import 'package:control_financiero/features/categorias/widgets/colors_single_child_scroll.dart';
import 'package:control_financiero/features/categorias/widgets/icons_single_child_scroll.dart';
import 'package:control_financiero/features/categorias/widgets/info_categoria_predeterminada.dart';
import 'package:control_financiero/features/categorias/widgets/tab_chip.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:control_financiero/features/shared/widgets/detail_category_card.dart';
import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:control_financiero/features/shared/widgets/text_input_card.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriaFormPage extends StatefulWidget {
  final CategoriaFormMode mode;
  final DetalleCategoria? categoriaExistente;

  const CategoriaFormPage({
    super.key,
    required this.mode,
    this.categoriaExistente,
  });

  @override
  State<CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends State<CategoriaFormPage> {
  late Color selectedColor;
  late IconData selectedIcon;
  late DetalleCategoria initialCategoria;
  bool _canCloseWindow = false;
  bool _isLoading = false;
  bool isDefault = false;
  bool isEditing = false;
  bool isEnabledRepeatMovement = false;
  bool _initialValueIsEnabledRepeatMovement = false;
  int categoryTypeID = -1;
  String categoryTypeName = 'Sin seleccionar';
  String selectedTipeMovement = 'gasto';
  TipoMovimiento get tipoMovimientoSeleccionado =>
      selectedTipeMovement == 'ingreso'
      ? TipoMovimiento.ingreso
      : TipoMovimiento.gasto;
  late List<TipoCategoria> tiposCategorias;
  late int movementsByCategory;
  final _categoryNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    movementsByCategory = 0;
    selectedColor = categoryColors.first;
    selectedIcon = categoryIcons.first;

    initialCategoria = DetalleCategoria(
      id: widget.categoriaExistente?.id ?? 0,
      name: widget.categoriaExistente?.name ?? '',
      description: widget.categoriaExistente?.description ?? '',
      icon: widget.categoriaExistente?.icon,
      color: widget.categoriaExistente?.color,
      movementType: widget.categoriaExistente != null
          ? (widget.categoriaExistente!.movementType)
          : TipoMovimiento.gasto,
      categoryTypeName: widget.categoriaExistente?.categoryTypeName ?? '',
      categoryTypeID: widget.categoriaExistente?.categoryTypeID ?? -1,
      enabledRepeatMovement:
          widget.categoriaExistente?.enabledRepeatMovement ?? false,
      isDefault: widget.categoriaExistente?.isDefault ?? false,
    );

    if (widget.mode == CategoriaFormMode.edit &&
        widget.categoriaExistente != null) {
      isEditing = true;
    }

    _categoryNameController.text = initialCategoria.name;
    _descriptionController.text = initialCategoria.description;
    selectedIcon = initialCategoria.icon ?? categoryIcons.first;
    selectedColor = initialCategoria.color ?? categoryColors.first;
    movementsByCategory = widget.categoriaExistente?.totalMovements ?? 0;
    categoryTypeName = initialCategoria.categoryTypeName;
    categoryTypeID = initialCategoria.categoryTypeID;
    selectedTipeMovement =
        initialCategoria.movementType == TipoMovimiento.ingreso
        ? 'ingreso'
        : 'gasto';
    isDefault = initialCategoria.isDefault;
    isEnabledRepeatMovement = initialCategoria.enabledRepeatMovement;
    _initialValueIsEnabledRepeatMovement =
        initialCategoria.enabledRepeatMovement;
  }

  @override
  void dispose() {
    // Limpiar los controladores al desechar el widget
    _categoryNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onChangeTipoCategoria(TipoCategoria? tipoCategoria) {
    if (tipoCategoria != null) {
      setState(() {
        categoryTypeID = tipoCategoria.id!;
        categoryTypeName = tipoCategoria.name;
      });
    }
  }

  void _onChangeTipoMovimiento(String tipoMovimiento) {
    setState(() {
      selectedTipeMovement = tipoMovimiento;
    });
  }

  Future<void> _guardarCategoria() async {
    final appState = context.read<AppState>();
    final nombre = _categoryNameController.text.trim();
    final descripcion = _descriptionController.text.trim();

    if (nombre.isEmpty) {
      AppSnackbar.error(
        context,
        'El nombre de la categoría no puede estar vacío.',
      );
      return;
    }

    if (categoryTypeID == -1) {
      AppSnackbar.warning(
        context,
        'Por favor, selecciona un tipo de categoría.',
      );
      return;
    }

    final confirmed = await showConfirmAddDialog(
      context,
      titleModal: 'Confirmar guardar categoría',
      content: [
        Text('Nombre: $nombre'),
        if (descripcion.isNotEmpty) Text('Descripción: $descripcion'),
        Text('Tipo de categoría: $categoryTypeName'),
        Text(
          'Tipo de movimiento: ${selectedTipeMovement == 'gasto' ? 'Gasto' : 'Ingreso'}',
        ),
        Text(
          'Permitir repetir movimientos cada mes: ${isEnabledRepeatMovement ? 'Sí' : 'No'}',
        ),
      ],
    );
    if (confirmed != true) return;

    setState(() {
      _canCloseWindow = true;
      _isLoading = true;
    });

    final categoria = Categoria(
      id:
          widget.mode == CategoriaFormMode.edit &&
              widget.categoriaExistente != null
          ? widget.categoriaExistente!.id
          : null,
      name: nombre,
      description: descripcion,
      categoryTypeID: categoryTypeID,
      iconName: IconMapper.toName(selectedIcon),
      iconColorValue: selectedColor.value,
      movementType: tipoMovimientoSeleccionado,
      enabledRepeatMovement: isEnabledRepeatMovement,
      isDefault: isDefault,
    );

    if (widget.mode == CategoriaFormMode.edit &&
        widget.categoriaExistente != null) {
      await appState.actualizarCategoria(categoria);
    } else {
      await appState.agregarCategoria(categoria);
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      setState(() {
        _canCloseWindow = false;
      });
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);

    Navigator.pop(context, true);
  }

  Future<void> _eliminarCategoria() async {
    final appState = context.read<AppState>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar categoría',
      content: '¿Estás seguro de que deseas eliminar esta categoría?',
    );
    if (confirmed != true) return;
    setState(() {
      _canCloseWindow = true;
      _isLoading = true;
    });

    await appState.eliminarCategoria(widget.categoriaExistente!.id);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      setState(() {
        _canCloseWindow = false;
      });
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);
    Navigator.pop(context, true);
  }

  void _toggleRepeatMovement(bool value) {
    if (_initialValueIsEnabledRepeatMovement && movementsByCategory > 0) {
      AppSnackbar.warning(
        context,
        'No puedes cambiar esta opción porque esta categoría tiene movimientos asociados.',
      );
      return;
    }

    setState(() {
      isEnabledRepeatMovement = value;
    });
  }

  bool _checkForChanges() {
    if (_canCloseWindow) return true;

    final original = initialCategoria;
    final current = DetalleCategoria(
      id: original.id,
      name: _categoryNameController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: selectedIcon,
      color: selectedColor,
      movementType: tipoMovimientoSeleccionado,
      categoryTypeName: categoryTypeName,
      categoryTypeID: categoryTypeID,
      enabledRepeatMovement: isEnabledRepeatMovement,
      isDefault: isDefault,
    );
    return original != current;
  }

  Future<bool> _onWillPop() async {
    final hasChanges = _checkForChanges();
    if (!hasChanges) return true;

    final shouldLeave = await showConfirmDialog(
      context,
      title: 'Salir sin guardar',
      content: 'Tienes cambios sin guardar. ¿Seguro que deseas salir?',
    );

    return shouldLeave == true;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    tiposCategorias = appState.tiposCategorias;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.mode == CategoriaFormMode.create
                ? 'Agregar Categoría'
                : isDefault
                ? 'Ver Categoría'
                : 'Editar Categoría',
          ),
          actions: [
            if (widget.mode == CategoriaFormMode.edit &&
                widget.categoriaExistente != null &&
                !isDefault)
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: _isLoading ? Colors.grey : Colors.red,
                ),
                tooltip: 'Eliminar',
                onPressed: _isLoading
                    ? null
                    : () async {
                        await _eliminarCategoria();
                      },
              ),

            if (!isDefault)
              IconButton(
                icon: Icon(
                  Icons.check,
                  color: _isLoading ? Colors.grey : Colors.green,
                ),
                tooltip: 'Guardar',
                onPressed: _isLoading
                    ? null
                    : () async {
                        await _guardarCategoria();
                      },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _isLoading
              ? LoadingScreen(message: 'Guardando categoría...')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  IconContainer(
                                    icon: selectedIcon,
                                    color: selectedColor,
                                    size: 64,
                                    onTap: () {
                                      if (isDefault) return;
                                      _openIconColorPickerModal(context);
                                    },
                                  ),
                                  if (!isDefault) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      "Toca el ícono para cambiar",
                                      style: TextStyle(
                                        color: selectedColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            WidgetsContainer(
                              title: 'Detalles de la categoría',
                              children: [
                                TextInputCard(
                                  textController: _categoryNameController,
                                  placeholder: 'Nombre de la categoría',
                                  iconData: Icons.label_outline,
                                  iconColor: Colors.grey.shade600,
                                  maxLines: 1,
                                  maxLength: 40,
                                  isEditable: !isDefault,
                                ),
                                TextInputCard(
                                  textController: _descriptionController,
                                  placeholder: 'Descripción (opcional)',
                                  iconData: Icons.description_outlined,
                                  iconColor: Colors.grey.shade600,
                                  maxLines: 3,
                                  maxLength: 80,
                                  isEditable: !isDefault,
                                ),
                              ],
                            ),
                            WidgetsContainer(
                              title: 'Opciones adicionales',
                              description: !isEditing
                                  ? 'Configura opciones adicionales para esta categoría.'
                                  : 'No puedes cambiar estas opciones para categorías predeterminadas o al editar.',
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (isDefault || isEditing) return;
                                    _openTipoCategoriasModal(context);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: DetailCategoryCard(
                                    categoryName: 'Tipo de categoría',
                                    categoryIcon: Icons.category,
                                    iconColor: Colors.blue,
                                    currentValue: categoryTypeName,
                                    showArrow: (!isDefault && !isEditing),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (isDefault || isEditing) return;
                                    _onChangeTipoMovimiento(
                                      selectedTipeMovement == 'gasto'
                                          ? 'ingreso'
                                          : 'gasto',
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: DetailCategoryCard(
                                    categoryName: 'Tipo de movimiento',
                                    categoryIcon:
                                        selectedTipeMovement == 'gasto'
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    iconColor: selectedTipeMovement == 'gasto'
                                        ? Colors.red
                                        : Colors.green,
                                    currentValue:
                                        selectedTipeMovement == 'gasto'
                                        ? 'Gasto'
                                        : 'Ingreso',
                                    showArrow: (!isDefault && !isEditing),
                                  ),
                                ),
                                DetailCategoryCard(
                                  categoryName:
                                      'Permitir repetir movimientos cada mes',
                                  categoryIcon: Icons.repeat,
                                  iconColor: Colors.green,
                                  showArrow: false,
                                  trailing: Switch(
                                    value: isEnabledRepeatMovement,
                                    onChanged: (value) {
                                      if (isDefault) return;
                                      _toggleRepeatMovement(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (movementsByCategory > 0)
                              WidgetsContainer(
                                title: 'Movimientos asociados',
                                description:
                                    'Esta categoría tiene movimientos asociados.\nPara eliminarla, primero elimina o reasigna esos movimientos.',
                                borderColor: Colors.orange,
                                children: [
                                  DetailCategoryCard(
                                    categoryName:
                                        'Cantidad de movimientos asociados',
                                    categoryIcon: Icons.list_alt,
                                    iconColor: Colors.purple,
                                    currentValue:
                                        '$movementsByCategory movimiento(s)',
                                    showArrow: false,
                                  ),
                                  // Aquí podrías agregar un botón o enlace para ver los movimientos asociados a esta categoría, si lo deseas.
                                ],
                              ),

                            if (widget.mode == CategoriaFormMode.edit)
                              InfoCategoriaPredeterminada(isDefault: isDefault),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _openIconColorPickerModal(BuildContext context) {
    IconData tempIcon = selectedIcon;
    Color tempColor = selectedColor;
    String selectedTab = 'icons';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// PREVIEW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vista previa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: IconContainer(
                      icon: tempIcon,
                      color: tempColor,
                      size: 72,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TabChip(
                        isSelected: selectedTab == 'icons',
                        tempColor: tempColor,
                        label: 'Íconos',
                        onTap: () {
                          setModalState(() {
                            selectedTab = 'icons';
                          });
                        },
                      ),
                      TabChip(
                        isSelected: selectedTab == 'colors',
                        tempColor: tempColor,
                        label: 'Colores',
                        onTap: () {
                          setModalState(() {
                            selectedTab = 'colors';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  /// ÍCONOS
                  if (selectedTab == 'icons')
                    SizedBox(
                      height: 200,
                      child: IconsSingleChildScroll(
                        tempIcon: tempIcon,
                        tempColor: tempColor,
                        onTap: (icon) {
                          setModalState(() {
                            tempIcon = icon;
                          });
                        },
                      ),
                    ),

                  /// COLORES
                  if (selectedTab == 'colors')
                    SizedBox(
                      height: 200,
                      child: ColorsSingleChildScroll(
                        tempColor: tempColor,
                        onTap: (color) {
                          setModalState(() {
                            tempColor = color;
                          });
                        },
                      ),
                    ),

                  const SizedBox(height: 6),

                  /// BOTÓN CONFIRMAR
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'icon': tempIcon,
                          'color': tempColor,
                        });
                      },
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          selectedIcon = result['icon'];
          selectedColor = result['color'];
        });
      }
    });
  }

  void _openTipoCategoriasModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true, // Muestra el indicador de arrastre
      builder: (_) {
        // Si la lista de categorías está vacía, mostrar un mensaje
        if (tiposCategorias.isEmpty) {
          return const Center(
            child: Text(
              'No hay categorías disponibles.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tiposCategorias.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final tipoCategoria = tiposCategorias[index];

            return ListTile(
              leading: IconContainer(
                icon: Icons.category,
                color: Colors.grey[800]!,
                size: 26,
              ),
              title: Text(
                tipoCategoria.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                tipoCategoria.description,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context, tipoCategoria);
              },
            );
          },
        );
      },
    ).then((tipoCategoriaSeleccionada) {
      if (tipoCategoriaSeleccionada != null) {
        _onChangeTipoCategoria(tipoCategoriaSeleccionada as TipoCategoria);
      }
    });
  }
}
