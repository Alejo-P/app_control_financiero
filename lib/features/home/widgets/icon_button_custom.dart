import 'package:flutter/material.dart';

class IconButtonCustom extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const IconButtonCustom({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Convert Color components (0..1) to 0..255 ints to avoid deprecated accessors
    final int r = ((color.r * 255.0).round().clamp(0, 255)).toInt();
    final int g = ((color.g * 255.0).round().clamp(0, 255)).toInt();
    final int b = ((color.b * 255.0).round().clamp(0, 255)).toInt();

    return ElevatedButton.icon(
      onPressed: onPressed, 
      icon: Icon(icon, color: color),
      label: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(r, g, b, 0.15),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
