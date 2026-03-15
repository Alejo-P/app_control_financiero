import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

class MonthAccordionCard extends StatelessWidget {
  final DateTime month;
  final double balance;
  final Widget content;

  const MonthAccordionCard({
    super.key,
    required this.month,
    required this.balance,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final balanceColor = balance >= 0
        ? Colors.green.shade600
        : Colors.red.shade600;

    final monthName = getMonthName(month);
    final firstDay = getFirstDayOfMonth(month);
    final lastDay = getLastDayOfMonth(month);

    final formatedFirstDate = formatDayMonth(firstDay);
    final formatedLastDate = formatDayMonth(lastDay);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          iconColor: colorScheme.primary,
          collapsedIconColor: colorScheme.primary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          title: Text(
            monthName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          subtitle: Text(
            "$formatedFirstDate - $formatedLastDate",
            style: theme.textTheme.bodySmall,
          ),

          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Balance", style: theme.textTheme.bodySmall),
              Text(
                balance >= 0
                    ? "+\$${balance.abs().toStringAsFixed(2)}"
                    : "-\$${balance.abs().toStringAsFixed(2)}",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: balanceColor,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          children: [content],
        ),
      ),
    );
  }
}
