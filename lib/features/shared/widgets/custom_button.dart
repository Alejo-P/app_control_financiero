import 'package:flutter/material.dart';

enum WidgetWidth { fitContent, fullWidth }

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData? icon;
  final String? text;
  final WidgetWidth width;

  const CustomButton({
    super.key,
    this.onTap,
    this.icon,
    this.text,
    this.width = WidgetWidth.fitContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: onTap == null ? 0.6 : 1.0,
      child: ElevatedButton(
        onPressed: onTap,
        style: theme.elevatedButtonTheme.style?.copyWith(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        child: icon != null && text != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: width == WidgetWidth.fullWidth
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                children: [
                  Icon(icon),
                  SizedBox(width: 6),
                  Text(
                    text!,
                    style: TextStyle().copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : icon != null
            ? Icon(icon)
            : Text(
                text!,
                style: TextStyle().copyWith(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
