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
  final bool isDefault;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onChange;
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
    this.isDefault = false,
    this.onTap,
    this.onChange,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: Card(
        elevation: 4,
        shape: isDefault ? RoundedRectangleBorder(
          side: BorderSide(color: Colors.orangeAccent),
          borderRadius: BorderRadius.all(Radius.circular(15))
        ) : null,
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
                onTap: onChange,
              ),
              Divider(),
              FooterRecordatorioCard(
                categoryName: categoryName,
                recurrency: recurrency,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
