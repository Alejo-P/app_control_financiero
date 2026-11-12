import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/historial/models/expense_analysis_page_args.dart';
import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:control_financiero/features/shared/widgets/text_input_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseAnalysisFormPage extends StatefulWidget {
  const ExpenseAnalysisFormPage({super.key});

  @override
  State<ExpenseAnalysisFormPage> createState() =>
      _ExpenseAnalysisFormPageState();
}

class _ExpenseAnalysisFormPageState extends State<ExpenseAnalysisFormPage> {
  ExpenseAnalysisPeriod? _period;
  DateTimeRange? _range;
  final _selectedIds = <int>{};
  final _concept = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_period != null) return;
    final args =
        ModalRoute.of(context)!.settings.arguments
            as ExpenseAnalysisFormPageArgs;
    _period = args.initialPeriod;
  }

  @override
  void dispose() {
    _concept.dispose();
    super.dispose();
  }

  void _clearFilters() {
    FocusScope.of(context).unfocus();
    _concept.clear();
    setState(() {
      _period = ExpenseAnalysisPeriod.allHistory;
      _range = null;
      _selectedIds.clear();
    });
  }

  Future<void> _selectPeriod(ExpenseAnalysisPeriod period) async {
    if (period != ExpenseAnalysisPeriod.custom) {
      setState(() => _period = period);
      return;
    }
    final today = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(today.year, 12, 31),
      initialDateRange: _range,
      helpText: 'Selecciona un rango de fechas',
      saveText: 'Aceptar',
    );
    if (!mounted || range == null) return;
    setState(() {
      _period = period;
      _range = range;
    });
  }

  Future<void> _selectCategories(List<Categoria> categories) async {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final selected = _selectedIds.toSet();
    final confirmed = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, updateSheet) => FractionallySizedBox(
          heightFactor: 0.75,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Categorías de gasto',
                                textAlign: TextAlign.center,
                                style: textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: () => updateSheet(() {
                                      selected.addAll(
                                        categories.map((c) => c.id!),
                                      );
                                    }),
                                    child: const Text('Marcar todas'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        updateSheet(selected.clear),
                                    child: const Text('Limpiar'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        final category = categories[index - 1];
                        return CheckboxListTile(
                          title: Text(
                            category.name,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          secondary: Icon(category.iconData),
                          value: selected.contains(category.id),
                          onChanged: (checked) => updateSheet(() {
                            if (checked == true) {
                              selected.add(category.id!);
                            } else {
                              selected.remove(category.id);
                            }
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    onTap: () => Navigator.pop(context, selected.toSet()),
                    icon: Icons.check,
                    text: 'Listo',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!mounted || confirmed == null) return;
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(confirmed);
    });
  }

  void _showResults(List<Categoria> selected, DateTime today) {
    FocusScope.of(context).unfocus();
    Navigator.pushNamed<void>(
      context,
      AppRoutes.expenseAnalysisResultsRoute,
      arguments: ExpenseAnalysisResultsPageArgs(
        period: _period!,
        today: today,
        categories: selected,
        concept: _concept.text,
        customRange: _range,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context
        .watch<AppState>()
        .categorias
        .where((c) => c.id != null && c.movementType == TipoMovimiento.gasto)
        .toList();
    final selected = categories
        .where((c) => _selectedIds.contains(c.id))
        .toList();
    final today = DateTime.now();
    final range = _range;
    final canSearch =
        selected.isNotEmpty &&
        (_period != ExpenseAnalysisPeriod.custom || range != null);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de gastos'),
        actions: [
          IconButton(
            onPressed: _clearFilters,
            tooltip: 'Limpiar filtros',
            icon: const Icon(Icons.filter_alt_off),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Consulta personalizada',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('Elige los filtros para consultar tus gastos.'),
            const SizedBox(height: 16),
            _FilterCard(
              title: 'Período',
              icon: Icons.calendar_today_outlined,
              required: true,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final period in ExpenseAnalysisPeriod.values)
                      ChoiceChip(
                        label: Text(period.optionLabel(today)),
                        labelStyle: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        checkmarkColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        selected: _period == period,
                        onSelected: (_) => _selectPeriod(period),
                        selectedColor: Colors.transparent,
                      ),
                  ],
                ),
                if (_period == ExpenseAnalysisPeriod.custom && range != null)
                  Text(
                    '${formatDate(range.start)} – ${formatDate(range.end)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
            _FilterCard(
              title: 'Categorías',
              icon: Icons.category_outlined,
              required: true,
              children: [
                OutlinedButton.icon(
                  onPressed: categories.isEmpty
                      ? null
                      : () => _selectCategories(categories),
                  icon: const Icon(Icons.expand_more),
                  label: const Text('Seleccionar categorías'),
                ),
                if (selected.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        for (final category in selected)
                          InputChip(
                            key: ValueKey(category.id),
                            avatar: Icon(
                              category.iconData,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: Text(
                              category.name,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            side: BorderSide(color: theme.colorScheme.primary),
                            deleteButtonTooltipMessage:
                                'Quitar ${category.name}',
                            deleteIconColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            onDeleted: () => setState(() {
                              _selectedIds.remove(category.id);
                            }),
                          ),
                      ],
                    ),
                  ),
                Text(
                  categories.isEmpty
                      ? 'No hay categorías de gasto.'
                      : selected.isEmpty
                      ? 'Selecciona al menos una categoría.'
                      : '${selected.length} de ${categories.length} categorías seleccionadas',
                ),
              ],
            ),
            _FilterCard(
              title: 'Buscar por concepto',
              icon: Icons.search,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _concept,
                  builder: (context, value, child) => TextInputCard(
                    textController: _concept,
                    placeholder: 'Concepto',
                    iconData: Icons.search,
                    iconColor: Colors.blue,
                    maxLines: 1,
                    maxLength: 50,
                  ),
                ),
                const Text('Busca gastos por su concepto.'),
              ],
            ),
            CustomButton(
              onTap: canSearch ? () => _showResults(selected, today) : null,
              icon: Icons.manage_search,
              text: 'Obtener resultados',
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.transparent,
              elevation: 0,
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue),
                title: Text(
                  'La consulta conserva intactos los gastos guardados.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.title,
    required this.icon,
    required this.children,
    this.required = false,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Icon(icon, color: theme.colorScheme.primary),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  required ? 'Obligatorio' : 'Opcional',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: required ? Colors.redAccent : Colors.green,
                  ),
                ),
              ],
            ),
            for (final child in children) ...[const SizedBox(height: 8), child],
          ],
        ),
      ),
    );
  }
}
