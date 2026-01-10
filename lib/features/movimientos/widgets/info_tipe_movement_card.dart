import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:flutter/material.dart';

class InfoTipeMovementCard extends StatelessWidget {
  final TipoMovimiento tipoMovimiento;

  const InfoTipeMovementCard({super.key, required this.tipoMovimiento});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: tipoMovimiento == TipoMovimiento.gasto
                ? Colors.red.shade100
                : Colors.green.shade100,
          ),
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color: tipoMovimiento == TipoMovimiento.gasto
                    ? Colors.red.shade700
                    : Colors.green.shade700,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'Registrando como ${tipoMovimiento == TipoMovimiento.gasto ? 'gasto' : 'ingreso'}',
                style: TextStyle(
                  color: tipoMovimiento == TipoMovimiento.gasto
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
