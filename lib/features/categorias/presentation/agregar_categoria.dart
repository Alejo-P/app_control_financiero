import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/categoria_constants.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/features/categorias/widgets/colors_single_child_scroll.dart';
import 'package:control_financiero/features/categorias/widgets/icons_single_child_scroll.dart';
import 'package:control_financiero/features/categorias/widgets/info_categoria_predeterminada.dart';
import 'package:control_financiero/features/categorias/widgets/tab_chip.dart';
import 'package:control_financiero/features/shared/widgets/detail_category_card.dart';
import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:control_financiero/features/shared/widgets/text_input_card.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgregarCategoria extends StatefulWidget {
  const AgregarCategoria({super.key});

  @override
  State<AgregarCategoria> createState() => _AgregarCategoriaState();
}

class _AgregarCategoriaState extends State<AgregarCategoria> {
  late Color selectedColor;
  late IconData selectedIcon;
  bool _hasUnsavedChanges = false;
  bool isDefault = false;
  int categoryTypeID = -1;
  String categoryTypeName = 'Sin seleccionar';
  late List<TipoCategoria> tiposCategorias;
  final _categoryNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedColor = categoryColors.first;
    selectedIcon = categoryIcons.first;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    tiposCategorias = appState.tiposCategorias;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Categoría'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Guardar',
            onPressed: () {
              // Lógica para guardar la nueva categoría
              debugPrint('Guardar nueva categoría');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  IconContainer(
                    icon: selectedIcon,
                    color: selectedColor,
                    size: 64,
                    onTap: () => _openIconColorPickerModal(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Cambiar ícono",
                    style: TextStyle(
                      color: selectedColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            WidgetsContainer(
              title: 'Detalles de la categoría',
              children: [
                TextInputCard(
                  textController: _categoryNameController,
                  placeholder: 'Nombre de la categoría',
                  iconData: Icons.label_outline,
                  iconColor: Colors.grey.shade600,
                ),
                TextInputCard(
                  textController: _descriptionController,
                  placeholder: 'Descripción (opcional)',
                  iconData: Icons.description_outlined,
                  iconColor: Colors.grey.shade600,
                ),
              ],
            ),
            const SizedBox(height: 16),
            WidgetsContainer(
              title: 'Opciones adicionales',
              children: [
                InkWell(
                  onTap: () => _openTipoCategoriasModal(context),
                  borderRadius: BorderRadius.circular(12),
                  child: DetailCategoryCard(
                    categoryName: 'Tipo de categoría',
                    categoryIcon: Icons.category,
                    iconColor: Colors.blue,
                    currentValue: categoryTypeName,
                  ),
                ),
              ],
            ),
            InfoCategoriaPredeterminada(isDefault: isDefault),
          ],
        ),
      ),
    );
  }

  void _openIconColorPickerModal(BuildContext context) {
    IconData tempIcon = selectedIcon;
    Color tempColor = selectedColor;
    String selectedTab = 'icons';
    final [r, g, b] = getRGBFromColor(Colors.grey);

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
                        backgroundColor: Color.fromRGBO(r, g, b, 0.1),
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
                          color: Colors.black,
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
            final [r, g, b] = getRGBFromColor(Colors.grey[800]!);

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color.fromRGBO(r, g, b, 0.15),
                child: Icon(Icons.category, color: Colors.grey[800]),
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
        setState(() {
          _hasUnsavedChanges = true;
          categoryTypeID = tipoCategoriaSeleccionada.id;
          categoryTypeName = tipoCategoriaSeleccionada.name;
        });
      }
    });
  }
}
