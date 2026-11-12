import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/historial/models/expense_analysis_page_args.dart';
import 'package:control_financiero/features/historial/widgets/report_charts.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/shared/widgets/custom_progress_bar.dart';
import 'package:control_financiero/features/shared/widgets/text_input_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseAnalysisResultsPage extends StatefulWidget {
  const ExpenseAnalysisResultsPage({super.key});

  @override
  State<ExpenseAnalysisResultsPage> createState() =>
      _ExpenseAnalysisResultsPageState();
}

class _ExpenseAnalysisResultsPageState
    extends State<ExpenseAnalysisResultsPage> {
  late ExpenseAnalysisResultsPageArgs _filters;
  Future<List<DetalleMovimiento>>? _expenses;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_expenses != null) return;
    _filters =
        ModalRoute.of(context)!.settings.arguments
            as ExpenseAnalysisResultsPageArgs;
    _expenses = _load();
  }

  Future<List<DetalleMovimiento>> _load() async {
    try {
      return await context.read<AppState>().fetchExpenseAnalysis(_filters);
    } catch (error, stack) {
      AppLogger.reportError('Análisis de gastos', error, stack);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análisis de gastos')),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<DetalleMovimiento>>(
          future: _expenses,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No se pudieron consultar los gastos.'),
                      FilledButton(
                        onPressed: () => setState(() => _expenses = _load()),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return _ExpenseResults(
              expenses: snapshot.requireData,
              filters: _filters,
            );
          },
        ),
      ),
    );
  }
}

class _ExpenseResults extends StatefulWidget {
  const _ExpenseResults({required this.expenses, required this.filters});

  final List<DetalleMovimiento> expenses;
  final ExpenseAnalysisResultsPageArgs filters;

  @override
  State<_ExpenseResults> createState() => _ExpenseResultsState();
}

class _ExpenseResultsState extends State<_ExpenseResults> {
  static const _pageSize = 20;
  final _selectionExceptions = <int>{};
  final _scroll = ScrollController();
  bool _includeByDefault = true;
  bool _oldestFirst = false;
  int _page = 0;
  late List<DetalleMovimiento> _matches;
  late final double _originalTotal;
  late double _includedTotal;
  final _term = TextEditingController();

  @override
  void initState() {
    super.initState();
    _matches = widget.expenses;
    _originalTotal = widget.expenses.fold(
      0,
      (total, expense) => total + expense.amount,
    );
    _includedTotal = _originalTotal;

    _term.addListener(_search);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _term.dispose();
    super.dispose();
  }

  int get _totalCount => widget.expenses.length;

  int get _includedCount => _includeByDefault
      ? _totalCount - _selectionExceptions.length
      : _selectionExceptions.length;

  bool _isIncluded(DetalleMovimiento expense) =>
      _includeByDefault != _selectionExceptions.contains(expense.id);

  void _toggleExpense(DetalleMovimiento expense) {
    setState(() {
      final included = _isIncluded(expense);
      if (!_selectionExceptions.remove(expense.id)) {
        _selectionExceptions.add(expense.id!);
      }
      _includedTotal = switch (_includedCount) {
        0 => 0,
        final count when count == _totalCount => _originalTotal,
        _ => _includedTotal + (included ? -expense.amount : expense.amount),
      };
    });
  }

  void _toggleAll() {
    setState(() {
      _includeByDefault = _includedCount != _totalCount;
      _selectionExceptions.clear();
      _includedTotal = _includeByDefault ? _originalTotal : 0;
    });
  }

  void _search() {
    final term = _term.text.trim().toLowerCase();
    setState(() {
      _matches = term.isEmpty
          ? widget.expenses
          : widget.expenses
                .where((expense) => expense.title.toLowerCase().contains(term))
                .toList();
      _page = 0;
    });
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = widget.filters;
    final filterLabels = [
      'Período: ${filters.periodLabel}',
      for (final category in filters.categories) category.name,
      if (filters.concept.isNotEmpty) 'Concepto: ${filters.concept}',
    ];
    final first = _page * _pageSize;
    final end = (first + _pageSize).clamp(0, _matches.length);
    final visibleExpenses = [
      for (int index = first; index < end; index++)
        _matches[_oldestFirst ? _matches.length - 1 - index : index],
    ];
    final included = _includedCount;
    final excluded = _totalCount - included;
    final [rBorder, gBorder, bBorder] = getRGBFromColor(Colors.grey.shade600);

    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Consulta personalizada',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Suma incluida',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  reportMoney(_includedTotal),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Total original: ${reportMoney(_originalTotal)} '
                  '($excluded ${excluded == 1 ? 'excluido' : 'excluidos'})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _SummaryMetric(
                      title: 'Gastos incluidos',
                      value: '$included de $_totalCount',
                      progress: _totalCount == 0 ? 0 : included / _totalCount,
                    ),
                    _SummaryMetric(
                      title: 'Promedio por gasto',
                      value: reportMoney(
                        included == 0 ? 0 : _includedTotal / included,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Marca o desmarca gastos para ajustar la suma.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Filtros aplicados',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < filterLabels.length; index += 2)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(
                        filterLabels[index],
                        maxLines: 1,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                    if (index + 1 < filterLabels.length)
                      Chip(
                        label: Text(
                          filterLabels[index + 1],
                          maxLines: 1,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Gastos encontrados ($_totalCount)',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_totalCount == 0)
          const Text('No se encontraron gastos con estos filtros.')
        else ...[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Color.fromRGBO(rBorder, gBorder, bBorder, 0.5),
                width: 1.5,
              ),
            ),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextInputCard(
                textController: _term,
                placeholder: 'Buscar en resultados',
                iconData: Icons.search_rounded,
                iconColor: Colors.blue,
                maxLines: 1,
                maxLength: 50,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: PopupMenuButton<bool>(
              tooltip: 'Ordenar gastos por fecha',
              initialValue: _oldestFirst,
              onSelected: (oldestFirst) => setState(() {
                _oldestFirst = oldestFirst;
                _page = 0;
              }),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: false,
                  child: Text(
                    'Más recientes',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: true,
                  child: Text(
                    'Más antiguos',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _oldestFirst ? 'Más antiguos ↑' : 'Más recientes ↓',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                CheckboxListTile(
                  tristate: true,
                  value: included == 0
                      ? false
                      : excluded == 0
                      ? true
                      : null,
                  title: Text(
                    'Selección de toda la consulta\n'
                    '($included de $_totalCount)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onChanged: (_) => _toggleAll(),
                ),
                TextButton(
                  onPressed: _toggleAll,
                  child: Text(
                    excluded == 0 ? 'Desmarcar todos' : 'Marcar todos',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_matches.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Ningún gasto coincide con la búsqueda en resultados.',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          else ...[
            for (final expense in visibleExpenses)
              _ExpenseRow(
                key: ValueKey(expense.id),
                expense: expense,
                included: _isIncluded(expense),
                onChanged: () => _toggleExpense(expense),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text(
                    'Mostrando ${first + 1}–$end de ${_matches.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: _page == 0 ? null : () => _goToPage(_page - 1),
                    child: Text(
                      'Anterior',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: end == _matches.length
                        ? null
                        : () => _goToPage(_page + 1),
                    child: Text(
                      'Siguiente',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.title,
    required this.value,
    this.progress,
  });

  final String title;
  final String value;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        if (progress != null)
          SizedBox(
            width: 96,
            child: CustomProgressBar(
              currentValue: progress ?? 0,
              color: theme.colorScheme.primary,
              minHeight: 5,
            ),
          ),
      ],
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    super.key,
    required this.expense,
    required this.included,
    required this.onChanged,
  });

  final DetalleMovimiento expense;
  final bool included;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: included,
        onChanged: (_) => onChanged(),
        title: Wrap(
          spacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(
              expense.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              reportMoney(expense.amount),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: included ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${expense.categoryName} · ${formatDate(expense.date)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
