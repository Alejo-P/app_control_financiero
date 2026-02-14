import 'package:flutter/material.dart';

class CategoryButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryButton({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bgColor = widget.isSelected ? colors.primary : colors.surface;

    final textColor = widget.isSelected ? colors.primary : colors.onSurface;

    final iconColor = widget.isSelected ? colors.onPrimary : colors.onSurface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(
                  color: !widget.isSelected
                      ? colors.primary
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(widget.icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: widget.isSelected
                    ? FontWeight.bold
                    : FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
