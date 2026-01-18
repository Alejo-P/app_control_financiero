import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class WidgetsContainer extends StatelessWidget {
  final String title;
  final String? summaryAmount;
  final TextStyle? summaryAmountStyle;
  final String? description;
  final List<Widget>? children;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final Color borderColor;

  const WidgetsContainer({
    super.key,
    required this.title,
    this.summaryAmount,
    this.summaryAmountStyle,
    this.description,
    this.children,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(8),
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundThemeColor =
        Theme.of(context).colorScheme.surface; // Color de fondo del tema
    final [r, g, b] = getRGBFromColor(backgroundThemeColor);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                summaryAmount ?? '',
                style: summaryAmountStyle,
              ),
            ],
          ),
          if (children != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor ?? backgroundThemeColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(r, g, b, 0.15),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: children!.length,
                separatorBuilder: (context, index) => const Divider(height: 8),
                itemBuilder: (context, index) => children![index],
              ),
            ),
          ],
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}
