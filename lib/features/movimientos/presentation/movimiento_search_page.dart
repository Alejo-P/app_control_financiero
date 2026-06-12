import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/widgets/transactions_container.dart';
import 'package:control_financiero/features/shared/widgets/label_card.dart';
import 'package:control_financiero/features/shared/widgets/text_input_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovimientoSearchPage extends StatefulWidget {
  final List<Categoria> listaCategorias;

  const MovimientoSearchPage({super.key, required this.listaCategorias});

  @override
  State<MovimientoSearchPage> createState() => _MovimientoSearchPageState();
}

class _MovimientoSearchPageState extends State<MovimientoSearchPage> {
  final _searchController = TextEditingController();
  List<Movimiento> listaMovimientos = [];
  List<Movimiento> movimientosFiltrados = [];
  List<DateTime> fechasUnicas = [];
  bool _isLoading = false;
  int _requestId = 0;
  int categoriaSeleccionada = -1;
  IconData? iconoCategoriaSeleccionada;
  Color? colorCategoriaSeleccionada;

  @override
  void initState() {
    super.initState();

    final categorias = widget.listaCategorias;

    if (categorias.isNotEmpty) {
      categoriaSeleccionada = categorias.first.id!;
      iconoCategoriaSeleccionada = categorias.first.iconData;
      colorCategoriaSeleccionada = categorias.first.iconColor;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await obtenerMovimientosPorcategoria(categoriaSeleccionada);
    });

    _searchController.addListener(_onSearchTerm);
  }

  @override
  void dispose() {
    // Limpiar los controladores al desechar el widget
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTerm() {
    final termino = _searchController.text.trim();
    if (termino.isEmpty) {
      setState(() {
        movimientosFiltrados = listaMovimientos;
      });
      return;
    }

    final terminoLower = termino.toLowerCase();
    final movsResultantes = listaMovimientos
        .where((mov) => mov.title.toLowerCase().contains(terminoLower))
        .toList();

    setState(() {
      movimientosFiltrados = movsResultantes;
    });
  }

  void _cleanInput() {
    _searchController.text = '';
  }

  Future<void> _onChangeCategoria(int categoriaId) async {
    if (categoriaSeleccionada == categoriaId) return;

    try {
      final categoria = widget.listaCategorias.firstWhere((cat) => cat.id == categoriaId);
      
      setState(() {
        categoriaSeleccionada = categoriaId;
        iconoCategoriaSeleccionada = categoria.iconData;
        colorCategoriaSeleccionada = categoria.iconColor;
      });
      
      await obtenerMovimientosPorcategoria(categoriaSeleccionada);
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

  Future<void> obtenerMovimientosPorcategoria(int categoryID) async {
    final appState = context.read<AppState>();
    final requestId = ++_requestId;

    setState(() => _isLoading = true);

    final movimientos = await appState.obtenerMovimientosPorCategoria(
      categoryID,
    );

    if (!mounted) return;

    if (requestId != _requestId) return; // ← ignora respuestas viejas

    final fechas = appState.fetchUniqueMovementDatesInList(movimientos);

    setState(() {
      fechasUnicas = fechas;
      listaMovimientos = movimientos;
      _isLoading = false;
    });

    _onSearchTerm(); // Realizar el filtrado si hay termino a buscar
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final categorias = widget.listaCategorias;
    final [rBorder, gBorder, bBorder] = getRGBFromColor(Colors.grey.shade600);

    final dropDownBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );

    if (categorias.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Buscar Movimientos')),

        body: const Center(
          child: Text(
            'No hay categorías para filtrar',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Movimientos'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt_off,
              color: (_isLoading || _searchController.text.isEmpty)
                  ? Colors.grey
                  : Colors.blue,
            ),
            tooltip: 'Limpiar campo de busqueda',
            onPressed: (_isLoading || _searchController.text.isEmpty)
                ? null
                : _cleanInput,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Color.fromRGBO(rBorder, gBorder, bBorder, 0.5),
                  width: 1.5,
                ),
              ),
              color: colors.surface,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextInputCard(
                      textController: _searchController,
                      placeholder: 'Buscar por nombre o concepto...',
                      iconData: Icons.search,
                      iconColor: Colors.grey.shade600,
                      maxLines: 1,
                      maxLength: 50,
                    ),

                    const Divider(height: 20, thickness: 1.5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        LabelCard(
                          label: "Filtrar por categoría",
                          iconData: iconoCategoriaSeleccionada,
                          iconColor: colorCategoriaSeleccionada,
                          textStyle: textTheme.bodyMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: categoriaSeleccionada,
                            decoration: InputDecoration(
                              border: dropDownBorder,
                              enabledBorder: dropDownBorder,
                              focusedBorder: dropDownBorder,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: colors.primary.withOpacity(0.2),
                            ),
                            items: categorias.map((categoria) {
                              return DropdownMenuItem<int>(
                                value: categoria.id!,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(categoria.iconData, size: 20),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        categoria.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            selectedItemBuilder: (context) {
                              return categorias.map((categoria) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        categoria.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList();
                            },
                            onChanged: (value) {
                              if (value == null) return;
                              _onChangeCategoria(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const _CustomLoading()
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 12),

                        Text("Resultados", style: textTheme.labelLarge),

                        if (movimientosFiltrados.isEmpty)
                          const _EmptyResults()
                        else
                          ...fechasUnicas.map((fecha) {
                            final movsPorFecha = movimientosFiltrados
                                .where((mov) => isSameDay(mov.date, fecha))
                                .toList();

                            if (movsPorFecha.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return TransactionsContainer(
                              date: fecha,
                              movimientos: movsPorFecha,
                            );
                          }),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No existen movimientos para la busqueda actual',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CustomLoading extends StatelessWidget {
  const _CustomLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            "Obteniendo movimientos...",
            style: textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
