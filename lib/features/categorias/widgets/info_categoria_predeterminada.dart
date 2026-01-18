import 'package:flutter/material.dart';

class InfoCategoriaPredeterminada extends StatelessWidget {
  final bool isDefault;

  const InfoCategoriaPredeterminada({super.key, required this.isDefault});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: isDefault
                ? Colors.orange.shade100
                : Colors.grey.shade200,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDefault ? Icons.lock : Icons.lock_open,
                color: isDefault
                    ? Colors.orange.shade700
                    : Colors.grey.shade700,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isDefault
                    ? 'Esta es una categoría predeterminada'
                    : 'Esta categoría no es predeterminada',
                style: TextStyle(
                  color: isDefault
                      ? Colors.orange.shade700
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}