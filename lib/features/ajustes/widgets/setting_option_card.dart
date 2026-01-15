import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class SettingOptionCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const SettingOptionCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final [r, g, b] = getRGBFromColor(iconColor);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color.fromRGBO(r, g, b, 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                ],
              ),
            ),
            if (onTap != null)
               Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
