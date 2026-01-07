import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final String title;
  final String ammount;
  final IconData icon;
  final Color iconColor;

  const DetailCard({
    super.key,
    required this.title,
    required this.ammount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final int r = ((iconColor.r * 255.0).round().clamp(0, 255)).toInt();
    final int g = ((iconColor.g * 255.0).round().clamp(0, 255)).toInt();
    final int b = ((iconColor.b * 255.0).round().clamp(0, 255)).toInt();
    
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.black54),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(r, g, b, 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '\$$ammount',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
