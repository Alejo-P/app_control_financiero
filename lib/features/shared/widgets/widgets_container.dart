import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class WidgetsContainer extends StatelessWidget {
  final String title;
  final String? summaryAmount;
  final TextStyle? summaryAmountStyle;
  final String? description;
  final List<Widget>? children;
  final Color backgroundColor;

  const WidgetsContainer({
    super.key,
    required this.title,
    this.summaryAmount,
    this.summaryAmountStyle,
    this.description,
    this.children,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final [r, g, b] = getRGBFromColor(backgroundColor);

    return Container(
      padding: const EdgeInsets.all(8),
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
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
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
