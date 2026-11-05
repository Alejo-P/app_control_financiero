import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/historial/widgets/labeled_value.dart';
import 'package:control_financiero/features/shared/widgets/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/monthly_report.dart';
import '../models/monthly_report_page_args.dart';
import '../widgets/report_charts.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  late Future<MonthlyReport> _report;
  final _budgetScroll = ScrollController();
  int? _selectedCategory;
  bool _loaded = false;
  late MonthlyReportPageArgs _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _args = ModalRoute.of(context)!.settings.arguments as MonthlyReportPageArgs;
    _report = _load(_args);
    _loaded = true;
  }

  Future<MonthlyReport> _load(MonthlyReportPageArgs args) async {
    try {
      final appState = context.read<AppState>();
      return await appState.fetchMonthlyReport(args.month);
    } catch (error, stack) {
      AppLogger.recordError('Informe mensual', error, stack);
      rethrow;
    }
  }

  @override
  void dispose() {
    _budgetScroll.dispose();
    super.dispose();
  }

  String _month(DateTime value) => '${getMonthName(value)} ${value.year}';

  void _selectCategory(int id) => setState(() {
    _selectedCategory = _selectedCategory == id ? null : id;
  });

  @override
  Widget build(BuildContext context) {
    final current = isSameMonth(_args.month, currentDateTime);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Informe mensual')),
      body: SafeArea(
        top: false,
        child: FutureBuilder<MonthlyReport>(
          future: _report,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No se pudo cargar el informe mensual.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _report = _load(_args);
                          });
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final report = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      "RESUMEN DEL PERÍODO",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      _month(report.month).toUpperCase(),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _summary(report),
                _section(
                  'Comparativa mensual',
                  'Ingresos vs. gastos',
                  ReportBarChart(income: report.income, spent: report.spent),
                ),
                _distribution(report),
                _comparison(report),
                _budgets(report),
                _observations(report),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _section(
    String title,
    String? subtitle,
    Widget child, {
    IconData? chipIcon,
    String? chipText,
    Color? chipColor,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: .18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (subtitle != null)
                        Text(subtitle, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                if (chipText != null) ...[
                  const SizedBox(height: 8),
                  Chip(
                    avatar: Icon(
                      chipIcon,
                      size: 20,
                      color: chipColor ?? colorScheme.primary,
                    ),
                    label: Text(chipText),
                    backgroundColor:
                        chipColor?.withValues(alpha: 0.1) ??
                        colorScheme.primary.withValues(alpha: 0.1),
                    labelStyle: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                    shape: StadiumBorder(
                      side: BorderSide(color: chipColor ?? colorScheme.primary),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _summary(MonthlyReport report) {
    final scheme = Theme.of(context).colorScheme;
    Widget metric(
      String title,
      String value,
      String detail,
      IconData icon,
      Color color,
    ) => Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outline.withValues(alpha: .18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
    final metrics = [
      metric(
        'Ingresos',
        reportMoney(report.income),
        'Total percibido',
        Icons.south_west,
        reportIncomeColor,
      ),
      metric(
        'Gastos',
        reportMoney(report.spent),
        'Total gastado',
        Icons.north_east,
        reportExpenseColor,
      ),
      metric(
        'Balance',
        '${report.balance > 0 ? '+' : ''}${reportMoney(report.balance)}',
        report.balance > 0
            ? 'Superávit'
            : report.balance < 0
            ? 'Déficit'
            : 'Equilibrado',
        Icons.account_balance_wallet_outlined,
        scheme.primary,
      ),
      metric(
        'Ahorro relativo',
        report.savingsPercent == null
            ? 'No aplica'
            : reportPercent(report.savingsPercent!),
        'Del ingreso total',
        Icons.savings_outlined,
        scheme.primary,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns =
            constraints.maxWidth >= 340 &&
            MediaQuery.textScalerOf(context).scale(14) <= 20;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: twoColumns
                      ? (constraints.maxWidth - 10) / 2
                      : constraints.maxWidth,
                  child: metric,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _distribution(MonthlyReport report) {
    final categories = report.expenseCategories;
    final colors = reportCategoryColors(categories);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return _section(
      'Distribución de gastos',
      'Por categoría · Total: ${reportMoney(report.spent)}',
      categories.isEmpty
          ? const Text('Sin gastos registrados')
          : Column(
              children: [
                ReportDonut(
                  categories: categories,
                  colors: colors,
                  selectedId: _selectedCategory,
                  onSelected: _selectCategory,
                ),
                const SizedBox(height: 12),
                for (final category in categories)
                  Semantics(
                    selected: category.id == _selectedCategory,
                    button: true,
                    child: Material(
                      color: category.id == _selectedCategory
                          ? colors[category.id]!.withValues(alpha: .14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _selectCategory(category.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 6,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 13,
                                height: 13,
                                margin: const EdgeInsets.only(top: 3),
                                decoration: BoxDecoration(
                                  color: colors[category.id],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${category.count} movimientos',
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                flex: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      reportMoney(category.spent),
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      reportPercent(
                                        report.spent > 0
                                            ? category.spent /
                                                  report.spent *
                                                  100
                                            : 0,
                                      ),
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String _changeText(MonthlyReport report) {
    final change = report.expenseChange;
    return change > 0
        ? 'Aumentaron:'
        : change < 0
        ? 'Disminuyeron:'
        : 'Sin cambios:';
  }

  Widget _comparison(MonthlyReport report) {
    final percent = report.expenseChangePercent;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return _section(
      'Variación intermensual',
      'Frente a ${_month(report.previousMonth)}',
      chipIcon: percent == null
          ? Icons.info_outline
          : percent > 0
          ? Icons.trending_up
          : Icons.trending_down,
      chipText: percent == null
          ? 'Sin base porcentual'
          : '${percent > 0 ? '+' : ''}${reportPercent(percent)}',
      chipColor: percent == null
          ? null
          : percent > 0
          ? const Color(0xFFE0BD45)
          : const Color(0xFF81C784),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabeledValue(
            label: 'Gasto del mes anterior:',
            value: reportMoney(report.previousSpent),
          ),
          const SizedBox(height: 8),
          LabeledValue(
            label: 'Gasto del mes actual:',
            value: reportMoney(report.spent),
          ),
          const SizedBox(height: 8),
          LabeledValue(
            label: _changeText(report),
            value: reportMoney(report.expenseChange.abs()),
          ),
          const Divider(height: 24),
          Text(
            percent == null
                ? 'Sin base porcentual'
                : percent > 0
                ? 'Tus gastos aumentaron un ${reportPercent(percent.abs())} respecto al mes anterior. ¡Revisa tus hábitos de consumo!'
                : 'Tus gastos disminuyeron un ${reportPercent(percent.abs())} respecto al mes anterior. ¡Buen control presupuestario!',
            style: textTheme.bodySmall?.copyWith(
              color: percent == null
                  ? colorScheme.onSurfaceVariant
                  : percent > 0
                  ? const Color(0xFFE0BD45)
                  : const Color(0xFF81C784),
              fontStyle: percent == null
                  ? null
                  : percent > 0
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
          if (isSameMonth(report.month, currentDateTime)) ...[
            const SizedBox(height: 8),
            Text(
              'Mes en curso: se compara lo acumulado con el mes anterior completo.',
              style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Color _budgetColor(ReportBudgetStatus status) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (status) {
      ReportBudgetStatus.none => Theme.of(context).colorScheme.onSurfaceVariant,
      ReportBudgetStatus.healthy =>
        dark ? const Color(0xFF81C784) : const Color(0xFF247347),
      ReportBudgetStatus.inUse =>
        dark ? const Color(0xFFE0BD45) : const Color(0xFF806000),
      ReportBudgetStatus.nearLimit =>
        dark ? const Color(0xFFFFB36B) : const Color(0xFFA34700),
      ReportBudgetStatus.reached || ReportBudgetStatus.exceeded =>
        dark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
    };
  }

  String _budgetMessage(ReportCategory category) => switch (category.status) {
    ReportBudgetStatus.none => 'Sin presupuesto',
    ReportBudgetStatus.healthy => 'Dentro del presupuesto',
    ReportBudgetStatus.inUse => 'Presupuesto en uso',
    ReportBudgetStatus.nearLimit => 'Cerca del límite',
    ReportBudgetStatus.reached => 'Límite alcanzado',
    ReportBudgetStatus.exceeded =>
      'Excedido por ${reportMoney(category.spent - category.budget!)}',
  };

  Widget _budgets(MonthlyReport report) {
    final categories = report.budgetCategories;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return _section(
      'Estado de presupuestos',
      'Ejecución del límite mensual',
      categories.isEmpty
          ? const Text('Sin presupuestos ni gastos registrados')
          : SizedBox(
              height: 320,
              child: Scrollbar(
                controller: _budgetScroll,
                thumbVisibility: true,
                child: ListView.separated(
                  key: const Key('report-budget-list'),
                  controller: _budgetScroll,
                  padding: const EdgeInsets.only(right: 12),
                  primary: false,
                  itemCount: categories.length,
                  separatorBuilder: (_, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final color = _budgetColor(category.status);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                category.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Text(
                              category.budget == null
                                  ? reportMoney(category.spent)
                                  : '${reportMoney(category.spent)} / ${reportMoney(category.budget!)}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (category.ratio != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: CustomProgressBar(
                                  currentValue: category.ratio!
                                      .clamp(0, 1)
                                      .toDouble(),
                                  color: color,
                                  backgroundColor: colorScheme.onSurface
                                      .withOpacity(0.18),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                reportPercent(category.ratio! * 100),
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _budgetMessage(category),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (category.remaining != null &&
                                category.remaining! > 0)
                              Text(
                                'Restan ${reportMoney(category.remaining!)}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _observations(MonthlyReport report) {
    final categories = report.expenseCategories;
    final observations = <String>[
      if (categories.isNotEmpty)
        '${categories.first.name} fue tu categoría con mayor gasto: ${reportMoney(categories.first.spent)}.',
      report.balance > 0
          ? 'Tu balance mensual fue positivo: superávit de ${reportMoney(report.balance)}.'
          : report.balance < 0
          ? 'Tu balance mensual fue negativo: déficit de ${reportMoney(report.balance.abs())}.'
          : 'Tus ingresos y gastos están equilibrados.',
      '${_changeText(report)} respecto al mes anterior${report.expenseChangePercent == null ? ' (sin base porcentual)' : ' (${reportPercent(report.expenseChangePercent!.abs())})'}.',
    ];
    return _section(
      'Observaciones del mes',
      null,
      Column(
        children: [
          for (final observation in observations)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(observation)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
