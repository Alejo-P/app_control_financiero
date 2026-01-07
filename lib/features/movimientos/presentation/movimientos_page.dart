import 'package:flutter/material.dart';

class MovimientosPage extends StatelessWidget {
  const MovimientosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Página de Movimientos',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}