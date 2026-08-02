import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class LabelCard extends StatelessWidget {
  final String label;
  final IconData? iconData;
  final Color? iconColor;
  final TextStyle? textStyle;

  const LabelCard({
    super.key,
    required this.label,
    this.iconData,
    this.iconColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final [r, g, b] = getRGBFromColor(iconColor ?? Colors.grey);

    return Row(
      children: [
        if (iconData != null) ...[
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(r, g, b, 0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(iconData, size: 22, color: iconColor ?? Colors.grey),
          ),
        ],
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: textStyle,
        ),
      ],
    );
  }
}
