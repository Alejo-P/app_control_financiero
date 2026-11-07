import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/app_state.dart';
import '../../../core/utils/date_utils.dart';
import '../../movimientos/models/detalle_movimiento.dart';
import '../../movimientos/widgets/transaction_detail_card.dart';
import '../models/monthly_report.dart';
import '../widgets/report_budget_style.dart';
import '../widgets/report_charts.dart';

class CategoryReportPage extends StatefulWidget {
  final DateTime month;
  final ReportCategory category;
  final double totalSpent;
  final Color color;

  const CategoryReportPage({
    super.key,
    required this.month,
    required this.category,
    required this.totalSpent,
    required this.color,
  });

  @override
  State<CategoryReportPage> createState() => _CategoryReportPageState();
}

class _CategoryReportPageState extends State<CategoryReportPage> {
  final List<DetalleMovimiento> _movements = [];
  bool _oldestFirst = false;
  bool _loading = true;
  bool _exhausted = false;
  String? _error;
  int _loadId = 0;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
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
        widget.month,
        widget.category.id,
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );

  Widget _metric(String label, String value, {Color? color}) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: (color ?? Theme.of(context).colorScheme.primary).withValues(
        alpha: .06,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );

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
    final month = DateTime(widget.month.year, widget.month.month);
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
    final c = widget.category;
    final text = Theme.of(context).textTheme;
    final budgetColor = reportBudgetColor(context, c.status);
    final monthName = '${getMonthName(widget.month)} ${widget.month.year}';
    final lastDay = DateTime(widget.month.year, widget.month.month + 1, 0).day;
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
                        color: widget.color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(c.icon, color: widget.color, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: text.titleLarge),
                          Text(monthName, style: text.bodySmall),
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
                      style: text.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        reportMoney(c.spent),
                        style: text.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Acumulado del 1 al $lastDay de ${getMonthName(widget.month)}',
                      textAlign: TextAlign.center,
                      style: text.bodySmall,
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
                          widget.totalSpent > 0
                              ? c.spent / widget.totalSpent * 100
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
                    Text('Estado del presupuesto', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${reportBudgetMessage(c)}${c.ratio == null ? '' : ' (${reportPercent(c.ratio! * 100)})'}',
                      style: text.labelLarge?.copyWith(color: budgetColor),
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
                      style: text.bodySmall,
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
                    style: text.titleMedium,
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
                        _load(reset: true);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_movements.isNotEmpty)
                _box(
                  Column(
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
                          iconColor: m.categoryColor ?? widget.color,
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
                TextButton(onPressed: _load, child: const Text('Reintentar')),
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
                  onPressed: _load,
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
