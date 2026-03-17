import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/historial/widgets/accordeon_content.dart';
import 'package:control_financiero/features/historial/widgets/ammount_detail_card.dart';
import 'package:control_financiero/features/historial/widgets/month_accordeon_card.dart';
import 'package:control_financiero/features/movimientos/widgets/transaction_card.dart';
import 'package:control_financiero/features/shared/widgets/custom_progress_bar.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  late AppState _appState;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appState = context.read<AppState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState.clearAppBarActions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: isLoading
                ? LoadingScreen(
                    message: 'Cargando historial de ingresos y gastos',
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MonthAccordionCard(
                          month: DateTime(2026, 3, 1),
                          balance: 450.00,
                          initialExpanded: true,
                          content: AccordeonContent(
                            spent: 2000,
                            totalIncome: 2450,
                          ),
                        ),
                        MonthAccordionCard(
                          month: DateTime(2026, 2, 1),
                          balance: 500.00,
                          content: AccordeonContent(
                            spent: 2000,
                            totalIncome: 2500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
