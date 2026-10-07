// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:control_financiero/core/utils/responsive_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
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
  Timer? _debounce;
  final _resultsController = ScrollController();
  int _page = 0;
  int _total = 0;
  String? _loadError;
  List<DetalleMovimiento> movimientosFiltrados = [];
  List<DateTime> fechasUnicas = [];
  List<Categoria> categorias = [];
  DateTime? fechaInicio;
  DateTime? fechaFin;

  bool _isLoading = false;
  int _requestId = 0;
  int categoriaSeleccionada = -1;
  IconData? iconoCategoriaSeleccionada;
  Color? colorCategoriaSeleccionada;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    categorias = [
      Categoria(
        id: -1,
        name: 'Todas',
        description: '',
        movementType:
            TipoMovimiento.gasto, // Asignar un valor predeterminado válido
        categoryTypeID: 0,
        iconName: IconMapper.toName(Icons.category),
        iconColorValue: Colors.grey.value,
      ),
      ...widget.listaCategorias,
    ];

    if (categorias.isNotEmpty) {
      categoriaSeleccionada = categorias.first.id!;
      iconoCategoriaSeleccionada = categorias.first.iconData;
      colorCategoriaSeleccionada = categorias.first.iconColor;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _buscarMovimientos();
    });

    _searchController.addListener(_onSearchTerm);
  }

  @override
  void dispose() {
    // Limpiar los controladores al desechar el widget
    _debounce?.cancel();
    _resultsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTerm() {
    _debounce?.cancel();
    ++_requestId;
    setState(() {
      _isLoading = true;
      _page = 0;
    });
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _buscarMovimientos();
    });
  }

  void _cleanInput() {
    _searchController.clear();
  }

  Future<void> _buscarMovimientos({int page = 0}) async {
    _debounce?.cancel();
    if (!mounted) return;
    final appState = context.read<AppState>();
    final requestId = ++_requestId;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final result = await appState.buscarMovimientosPaginados(
        categoryId: categoriaSeleccionada,
        text: _searchController.text,
        startDate: fechaInicio,
        endDate: fechaFin,
        page: page,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        movimientosFiltrados = result.movimientos;
        fechasUnicas = appState.fetchUniqueMovementDatesInList(
          result.movimientos,
        );
        _total = result.total;
        _page = result.page;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            requestId == _requestId &&
            _resultsController.hasClients) {
          _resultsController.jumpTo(0);
        }
      });
    } catch (e, stackTrace) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _isLoading = false;
        _loadError =
            'No se pudieron cargar los movimientos. Intenta nuevamente.';
      });
      await AppLogger.log(
        'Error en búsqueda paginada: $e',
        level: LogLevel.error,
        tag: 'MovimientoSearchPage',
        stackTrace: stackTrace,
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

      await _buscarMovimientos();
    } on Exception catch (e, stackTrace) {
      await AppLogger.log(
        'Error al obtener movimientos por categoría: ${e.toString()}',
        level: LogLevel.error,
        tag: 'MovimientoSearchPage',
        stackTrace: stackTrace,
      );

      if (!mounted) return;
      AppSnackbar.error(
        context,
        'Ocurrió un error al obtener los movimientos para la categoría seleccionada. Por favor, intenta nuevamente.',
      );
    }
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

    if (!mounted) return;
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
                    : _loadError != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_loadError!, textAlign: TextAlign.center),
                            TextButton(
                              onPressed: () => _buscarMovimientos(page: _page),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        controller: _resultsController,
                        padding: EdgeInsets.zero,
                        children: [
                          const SizedBox(height: 12),

                          Text(
                            _total == 0
                                ? 'Resultados: 0'
                                : '${_page * 20 + 1}–${_page * 20 + movimientosFiltrados.length} de $_total resultados',
                            style: textTheme.labelLarge,
                          ),

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
                                onMovementChanged: () =>
                                    _buscarMovimientos(page: _page),
                              );
                            }),
                          if (_total > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  tooltip: 'Anterior',
                                  onPressed: _page > 0
                                      ? () =>
                                            _buscarMovimientos(page: _page - 1)
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                Text(
                                  'Página ${_page + 1} de ${(_total + 19) ~/ 20}',
                                ),
                                IconButton(
                                  tooltip: 'Siguiente',
                                  onPressed: (_page + 1) * 20 < _total
                                      ? () =>
                                            _buscarMovimientos(page: _page + 1)
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                ),
                              ],
                            ),
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
