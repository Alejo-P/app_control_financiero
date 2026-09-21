// ignore_for_file: deprecated_member_use

import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/responsive_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/movimientos/models/movimiento_search_filters.dart';
import 'package:control_financiero/features/movimientos/widgets/transactions_container.dart';
import 'package:control_financiero/features/shared/widgets/category_dropdown.dart';
import 'package:control_financiero/features/shared/widgets/labeled_form_field.dart';
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
  List<DetalleMovimiento> listaMovimientos = [];
  List<DetalleMovimiento> movimientosFiltrados = [];
  List<DateTime> fechasUnicas = [];
  DateTime? fechaInicio;
  DateTime? fechaFin;
  AgrupacionBusqueda agrupacion = AgrupacionBusqueda.ninguna;
  bool _isLoading = false;
  int _requestId = 0;
  int categoriaSeleccionada = -1;
  IconData? iconoCategoriaSeleccionada;
  Color? colorCategoriaSeleccionada;

  final _searchController = TextEditingController();

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
    _buscarMovimientos();
  }

  Future<void> _buscarMovimientos() async {
    final appState = context.read<AppState>();
    final requestId = ++_requestId;
    setState(() => _isLoading = true);

    List<DetalleMovimiento> movimientos = [];

    movimientos = await appState.obtenerMovimientosPorCategoria(
      categoriaSeleccionada,
    );

    if (_searchController.text.trim().isNotEmpty) {
      final terminoLower = _searchController.text.trim().toLowerCase();
      movimientos = movimientos
          .where((mov) => mov.title.toLowerCase().contains(terminoLower))
          .toList();
    }

    if (fechaInicio != null && fechaFin != null) {
      movimientos = movimientos.where((mov) {
        return !mov.date.isBefore(fechaInicio!) && !mov.date.isAfter(fechaFin!);
      }).toList();
    }

    if (!mounted) return;
    if (requestId != _requestId) return;

    final fechas = appState.fetchUniqueMovementDatesInList(movimientos);

    setState(() {
      listaMovimientos = movimientos;
      movimientosFiltrados = movimientos;
      fechasUnicas = fechas;
      _isLoading = false;
    });
  }

  Future<void> _onChangeCategoria(int categoriaId) async {
    if (categoriaSeleccionada == categoriaId) return;

    try {
      final categoria = widget.listaCategorias.firstWhere(
        (cat) => cat.id == categoriaId,
      );

      setState(() {
        categoriaSeleccionada = categoriaId;
        iconoCategoriaSeleccionada = categoria.iconData;
        colorCategoriaSeleccionada = categoria.iconColor;
      });

      await _buscarMovimientos();
    } on Exception catch (e, stackTrace) {
      if (!mounted) return;

      await AppLogger.log(
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

  void _onClearDateRange() {
    setState(() {
      fechaInicio = null;
      fechaFin = null;
    });
    _buscarMovimientos();
  }

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      helpText: 'Selecciona un rango de fechas',
      fieldStartLabelText: 'Fecha de inicio',
      fieldEndLabelText: 'Fecha de fin',
      fieldStartHintText: 'Fecha de inicio',
      fieldEndHintText: 'Fecha de fin',
      saveText: 'Aceptar',
      initialDateRange: (fechaInicio != null && fechaFin != null)
          ? DateTimeRange(start: fechaInicio!, end: fechaFin!)
          : null,
    );

    if (picked != null) {
      setState(() {
        fechaInicio = picked.start;
        fechaFin = picked.end;
      });
      await _buscarMovimientos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final categorias = widget.listaCategorias;
    final [rBorder, gBorder, bBorder] = getRGBFromColor(Colors.grey.shade600);
    final isSelectedRange = fechaInicio != null && fechaFin != null;

    if (categorias.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Buscar Movimientos')),

        body: SafeArea(
          top: false,
          child: const Center(
            child: Text(
              'No hay categorías para filtrar',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
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
      body: SafeArea(
        top: false,
        child: Padding(
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

                      const SizedBox(height: 12),

                      LabeledFormField(
                        label: "Categoría",
                        icon: Icon(Icons.category, color: Colors.orange),
                        child: CategoryDropdown(
                          categorias: categorias,
                          selectedValue: categoriaSeleccionada,
                          onChangeCategory: _onChangeCategoria,
                        ),
                      ),

                      const SizedBox(height: 12),

                      LabeledFormField(
                        label: "Por fecha",
                        icon: Icon(
                          Icons.date_range,
                          color: Colors.grey.shade600,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8.0,
                          children: [
                            if (isSelectedRange)
                              TextButton(
                                onPressed: _showDateRangePicker,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  backgroundColor: colors.primary.withOpacity(
                                    0.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: context.isPhone
                                    ? Icon(
                                        Icons.edit_calendar,
                                        color: colors.primary,
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_calendar,
                                            color: colors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Editar rango",
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: colors.primary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                              ),

                            TextButton(
                              onPressed: isSelectedRange
                                  ? _onClearDateRange
                                  : _showDateRangePicker,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                backgroundColor: colors.primary.withOpacity(
                                  0.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: context.isPhone
                                  ? Icon(
                                      isSelectedRange
                                          ? Icons.delete_outline
                                          : Icons.date_range,
                                      color: colors.primary,
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isSelectedRange
                                              ? Icons.delete_outline
                                              : Icons.date_range,
                                          color: colors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isSelectedRange
                                              ? 'Eliminar rango'
                                              : 'Seleccionar rango',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
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

                          if (isSelectedRange)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 4.0,
                                bottom: 12,
                              ),
                              child: Center(
                                child: Text(
                                  "Movimientos entre ${formatDate(fechaInicio!)} y ${formatDate(fechaFin!)}",
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

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
