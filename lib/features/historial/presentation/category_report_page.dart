import 'package:control_financiero/features/historial/models/category_report_page_args.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/movimientos/widgets/transaction_detail_card.dart';
import 'package:control_financiero/features/historial/widgets/report_budget_style.dart';
import 'package:control_financiero/features/historial/widgets/report_charts.dart';

class CategoryReportPage extends StatefulWidget {
  const CategoryReportPage({super.key});

  @override
  State<CategoryReportPage> createState() => _CategoryReportPageState();
}

class _CategoryReportPageState extends State<CategoryReportPage> {
  final List<DetalleMovimiento> _movements = [];
  bool _oldestFirst = false;
  bool _loading = true;
  bool _loaded = false;
  bool _exhausted = false;
  String? _error;
  int _loadId = 0;
  late CategoryReportPageArgs _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _args =
        ModalRoute.of(context)!.settings.arguments as CategoryReportPageArgs;
    _load(_args);
    _loaded = true;
  }

  Future<void> _load(CategoryReportPageArgs args, {bool reset = false}) async {
    final id = ++_loadId;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _movements.clear();
        _exhausted = false;
      }
    });
    try {
      final rows = await context.read<AppState>().fetchCategoryReportMovements(
        args.month,
        args.category.id,
        offset: _movements.length,
        oldestFirst: _oldestFirst,
      );
      if (!mounted || id != _loadId) return;
      setState(() {
        _movements.addAll(rows);
        _exhausted = rows.length < 10;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || id != _loadId) return;
      setState(() {
        _error = 'No se pudieron cargar los movimientos.';
        _loading = false;
      });
    }
  }

  Widget _box(Widget child) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );

  Widget _metric(String label, String value, {Color? color}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? colorScheme.primary).withValues(
          alpha: .06,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _metrics(List<Widget> children) => LayoutBuilder(
    builder: (context, constraints) {
      final stack =
          constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(14) > 20;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final child in children)
            SizedBox(
              width: stack
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 16) / 3,
              child: child,
            ),
        ],
      );
    },
  );

  String get _periodState {
    final now = currentDateTime;
    final month = DateTime(_args.month.year, _args.month.month);
    final current = DateTime(now.year, now.month);
    if (month.isBefore(current)) return 'Período finalizado';
    if (month.isAfter(current)) return 'Período futuro';
    final days = DateTime(now.year, now.month + 1, 0).day - now.day;
    return days == 0
        ? 'Último día del mes'
        : 'Restan $days día${days == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final c = _args.category;
    final budgetColor = reportBudgetColor(context, c.status);
    final monthName = '${getMonthName(_args.month)} ${_args.month.year}';
    final lastDay = DateTime(_args.month.year, _args.month.month + 1, 0).day;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de categoría')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          key: const PageStorageKey('category-report-scroll'),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _box(
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _args.color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(c.icon, color: _args.color, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: textTheme.titleLarge),
                          Text(monthName, style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _box(
                Column(
                  children: [
                    Text(
                      'Gasto total en ${c.name}',
                      textAlign: TextAlign.center,
                      style: textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        reportMoney(c.spent),
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Acumulado del 1 al $lastDay de ${getMonthName(_args.month)}',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    _metrics([
                      _metric('Movimientos', '${c.count}'),
                      _metric(
                        'Promedio / op.',
                        c.count == 0
                            ? 'No aplica'
                            : reportMoney(c.spent / c.count),
                      ),
                      _metric(
                        'Del gasto total',
                        reportPercent(
                          _args.totalSpent > 0
                              ? c.spent / _args.totalSpent * 100
                              : 0,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              _box(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Estado del presupuesto', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${reportBudgetMessage(c)}${c.ratio == null ? '' : ' (${reportPercent(c.ratio! * 100)})'}',
                      style: textTheme.labelLarge?.copyWith(color: budgetColor),
                    ),
                    if (c.ratio != null) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: c.ratio!.clamp(0, 1).toDouble(),
                        color: budgetColor,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .12),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                    if (c.budget != null) ...[
                      const SizedBox(height: 20),
                      _metrics([
                        _metric('Presupuesto', reportMoney(c.budget!)),
                        _metric(
                          'Gastado',
                          reportMoney(c.spent),
                          color: reportExpenseColor,
                        ),
                        _metric(
                          c.remaining! < 0 ? 'Excedido' : 'Disponible',
                          reportMoney(c.remaining!.abs()),
                          color: c.remaining! < 0
                              ? budgetColor
                              : reportIncomeColor,
                        ),
                      ]),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      '${c.budget == null ? monthName : 'Límite mensual para $monthName'} · $_periodState',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    'Movimientos del período (${c.count})',
                    style: textTheme.titleMedium,
                  ),
                  SizedBox(
                    width: MediaQuery.textScalerOf(context).scale(14) > 20
                        ? 240
                        : 145,
                    child: DropdownButton<bool>(
                      isExpanded: true,
                      value: _oldestFirst,
                      items: const [
                        DropdownMenuItem(
                          value: false,
                          child: Text('Más recientes'),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text('Más antiguos'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null || value == _oldestFirst) return;
                        _oldestFirst = value;
                        _load(_args, reset: true);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_movements.isNotEmpty)
                _box(
                  Column(
                    spacing: 8,
                    children: [
                      for (final m in _movements)
                        TransactionDetailCard(
                          title: m.title,
                          category: DateFormat(
                            'dd MMMM yyyy',
                            'es_EC',
                          ).format(m.date),
                          type: m.movementType.name,
                          spent: m.amount,
                          icon: m.categoryIcon,
                          iconColor: m.categoryColor ?? _args.color,
                          time: m.time ?? const TimeOfDay(hour: 0, minute: 0),
                        ),
                    ],
                  ),
                ),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (_error != null) ...[
                Text(_error!, textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => _load(_args, reset: true),
                  child: const Text('Reintentar'),
                ),
              ],
              if (!_loading && _error == null && _movements.isEmpty)
                _box(
                  const Text(
                    'Sin movimientos en este período.',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_movements.isNotEmpty)
                Text(
                  'Mostrando ${_movements.length} de ${c.count} movimientos',
                  textAlign: TextAlign.center,
                ),
              if (!_loading &&
                  _error == null &&
                  !_exhausted &&
                  _movements.length < c.count)
                TextButton.icon(
                  onPressed: () => _load(_args, reset: true),
                  icon: const Icon(Icons.expand_more),
                  label: const Text('Cargar más'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
