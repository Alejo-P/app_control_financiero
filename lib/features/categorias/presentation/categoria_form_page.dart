import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/categoria_constants.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/categorias/widgets/colors_single_child_scroll.dart';
import 'package:control_financiero/features/categorias/widgets/icons_single_child_scroll.dart';
import 'package:control_financiero/features/categorias/widgets/info_categoria_predeterminada.dart';
import 'package:control_financiero/features/categorias/widgets/tab_chip.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:control_financiero/features/shared/widgets/detail_category_card.dart';
import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:control_financiero/features/shared/widgets/text_input_card.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriaFormPage extends StatefulWidget {
  final CategoriaFormMode mode;
  final Categoria? categoriaExistente;

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
  bool _hasUnsavedChanges = false;
  bool isDefault = false;
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
    selectedColor = categoryColors.first;
    selectedIcon = categoryIcons.first;

    if (widget.mode == CategoriaFormMode.edit &&
        widget.categoriaExistente != null) {
      final categoria = widget.categoriaExistente!;
      _categoryNameController.text = categoria.name;
      _descriptionController.text = categoria.description;
      selectedIcon = IconMapper.fromName(categoria.iconName);
      selectedColor = Color(categoria.iconColorValue);
      categoryTypeID = categoria.categoryTypeID;
      selectedTipeMovement = categoria.movementType == TipoMovimiento.ingreso
          ? 'ingreso'
          : 'gasto';
      isDefault = categoria.isDefault;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final appState = context.read<AppState>();
        final tipoCategoria = appState.getCategoryTypeById(categoryTypeID);
        if (tipoCategoria == null) return;

        appState.countMovementsByCategory(categoria.id!);
        
        setState(() {
          categoryTypeName = tipoCategoria.name;
        });
      });
    }

    _categoryNameController.addListener(_markAsDirty);
    _descriptionController.addListener(_markAsDirty);
  }

  @override
  void dispose() {
    // Limpiar los controladores al desechar el widget
    _categoryNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _markAsDirty() {
    // Si el campo esta vacío, no marcar como sucio
    if (_categoryNameController.text.isEmpty &&
        _descriptionController.text.isEmpty) {
      setState(() {
        _hasUnsavedChanges = false;
      });
      return;
    }

    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _onChangeTipoCategoria(TipoCategoria? tipoCategoria) {
    if (tipoCategoria != null) {
      setState(() {
        categoryTypeID = tipoCategoria.id!;
        categoryTypeName = tipoCategoria.name;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _onChangeTipoMovimiento(String tipoMovimiento) {
    setState(() {
      selectedTipeMovement = tipoMovimiento;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _guardarCategoria() async {
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
      ],
    );
    if (confirmed != true) return;

    setState(() {
      _hasUnsavedChanges = false;
    });

    final categoria = Categoria(
      id: widget.mode == CategoriaFormMode.edit &&
              widget.categoriaExistente != null
          ? widget.categoriaExistente!.id
          : null,
      name: nombre,
      description: descripcion,
      categoryTypeID: categoryTypeID,
      iconName: IconMapper.toName(selectedIcon),
      iconColorValue: selectedColor.value,
      movementType: tipoMovimientoSeleccionado,
      isDefault: isDefault,
    );

    if (widget.mode == CategoriaFormMode.edit &&
        widget.categoriaExistente != null) {
      await context.read<AppState>().actualizarCategoria(categoria);
    } else {
      await context.read<AppState>().agregarCategoria(categoria);
    }

    if (mounted) {
      AppSnackbar.success(
        context,
        context.read<AppState>().transactionResultMessage,
      );
      Navigator.pop(context, true);
    }
  }

  Future <void> _eliminarCategoria() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar categoría',
      content:
          '¿Estás seguro de que deseas eliminar esta categoría?',
    );
    if (confirmed != true) return;

    await context.read<AppState>().eliminarCategoria(widget.categoriaExistente!.id!);

    if (mounted) {
      if (!context.read<AppState>().transactionSuccess) {
        AppSnackbar.error(
          context,
          context.read<AppState>().transactionResultMessage,
        );
        return;
      }
      AppSnackbar.success(
        context,
        context.read<AppState>().transactionResultMessage,
      );
      Navigator.pop(context, true);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

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
    movementsByCategory = appState.movementsByCategory;

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
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Eliminar',
                onPressed: () async {
                  await _eliminarCategoria();
                },
              ),

            if (!isDefault && _hasUnsavedChanges)
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                tooltip: 'Guardar',
                onPressed: () async {
                  await _guardarCategoria();
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
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
                            if (!isDefault)
                            ...[
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
                            isEditable: !isDefault,
                          ),
                          TextInputCard(
                            textController: _descriptionController,
                            placeholder: 'Descripción (opcional)',
                            iconData: Icons.description_outlined,
                            iconColor: Colors.grey.shade600,
                            isEditable: !isDefault,
                          ),
                        ],
                      ),
                      WidgetsContainer(
                        title: 'Opciones adicionales',
                        children: [
                          InkWell(
                            onTap: () {
                              if (isDefault) return;
                              _openTipoCategoriasModal(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: DetailCategoryCard(
                              categoryName: 'Tipo de categoría',
                              categoryIcon: Icons.category,
                              iconColor: Colors.blue,
                              currentValue: categoryTypeName,
                              showArrow: !isDefault,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (isDefault) return;
                              _onChangeTipoMovimiento(
                                selectedTipeMovement == 'gasto'
                                    ? 'ingreso'
                                    : 'gasto',
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: DetailCategoryCard(
                              categoryName: 'Tipo de movimiento',
                              categoryIcon: selectedTipeMovement == 'gasto'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              iconColor: selectedTipeMovement == 'gasto'
                                  ? Colors.red
                                  : Colors.green,
                              currentValue: selectedTipeMovement == 'gasto'
                                  ? 'Gasto'
                                  : 'Ingreso',
                              showArrow: !isDefault,
                            ),
                          ),
                        ],
                      ),
                      if (movementsByCategory > 0)
                        WidgetsContainer(
                          title: 'Movimientos asociados',
                          description: 'Esta categoría tiene movimientos asociados.\nPara eliminarla, primero elimina o reasigna esos movimientos.',
                          backgroundColor: Colors.orange.shade50,
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
                          ],
                        ),

                      if (widget.mode == CategoriaFormMode.edit )
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'icon': tempIcon,
                          'color': tempColor,
                        });
                      },
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          color: Colors.white,
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
          _hasUnsavedChanges = true;
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
