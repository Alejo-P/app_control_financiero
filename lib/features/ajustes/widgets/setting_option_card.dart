import 'package:control_financiero/features/shared/widgets/icon_container.dart';
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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            IconContainer(
              icon: icon,
              color: iconColor,
              size: 26,
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
