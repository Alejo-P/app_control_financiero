import 'package:flutter/material.dart';

class InputCard extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Widget child;
  final Widget? trailing;

  const InputCard({
    super.key,
    this.icon,
    this.iconColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (icon != null)
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor?.withOpacity(.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),

        Expanded(child: child),

        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
