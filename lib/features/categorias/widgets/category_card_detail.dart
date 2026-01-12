import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class CategoryCardDetail extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isDefault;

  const CategoryCardDetail({
    super.key,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    final [r, g, b] = getRGBFromColor(color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(r, g, b, 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
