import 'package:control_financiero/features/recordatorios/widgets/footer_recordatorio_card.dart';
import 'package:control_financiero/features/recordatorios/widgets/header_recordatorio_card.dart';
import 'package:flutter/material.dart';

class RecordatorioCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String categoryName;
  final String recurrency;
  final DateTime createdAt;
  final bool isEnabled;
  final ValueChanged<bool>? onTap;
  final VoidCallback? onDelete;

  const RecordatorioCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.categoryName,
    required this.recurrency,
    required this.createdAt,
    required this.isEnabled,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            HeaderRecordatorioCard(
              icon: icon,
              iconColor: iconColor,
              title: title,
              createdAt: createdAt,
              onDelete: onDelete,
              isEnabled: isEnabled,
              onTap: onTap,
            ),
            Divider(),
            FooterRecordatorioCard(
              categoryName: categoryName,
              recurrency: recurrency,
            ),
          ],
        ),
      ),
    );
  }
}
