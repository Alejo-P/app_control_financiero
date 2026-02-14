import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/widgets/category_grid.dart';
import 'package:control_financiero/features/movimientos/widgets/transactions_container.dart';
import 'package:control_financiero/features/presupuestos/widgets/category_button.dart';
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

  @override
  void initState() {
    super.initState();

    final categorias = widget.listaCategorias;

    if (categorias.isNotEmpty) {
      categoriaSeleccionada = categorias.first.id!;
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

    setState(() {
      categoriaSeleccionada = categoriaId;
    });

    await obtenerMovimientosPorcategoria(categoriaSeleccionada);
  }

  Future<void> obtenerMovimientosPorcategoria(int categoryID) async {
    final appState = context.read<AppState>();
    final requestId = ++_requestId;

    setState(() => _isLoading = true);

    final movimientos = await appState.obtenerMovimientosPorCategoria(
      categoryID,
    );

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
              ),
              color: colors.surface,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextInputCard(
                  textController: _searchController,
                  placeholder: 'Buscar por nombre o concepto...',
                  iconData: Icons.search,
                  iconColor: Colors.grey.shade600,
                  maxLines: 1,
                  maxLength: 50,
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

                        Text(
                          "Filtrar por categoria",
                          style: textTheme.labelLarge,
                        ),

                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: colors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              children: [
                                CategoryGrid(
                                  children: categorias.map((categoria) {
                                    return CategoryButton(
                                      icon: categoria.iconData,
                                      title: categoria.name,
                                      isSelected:
                                          categoriaSeleccionada == categoria.id,
                                      onTap: () =>
                                          _onChangeCategoria(categoria.id!),
                                    );
                                  }).toList(),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Desliza para ver mas categorias >",
                                      textAlign: TextAlign.right,
                                      style: textTheme.labelSmall!.copyWith(
                                        color: colors.primary
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

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
