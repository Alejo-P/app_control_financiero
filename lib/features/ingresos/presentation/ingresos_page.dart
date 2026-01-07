import 'package:flutter/material.dart';

class IngresosPage extends StatelessWidget {
  const IngresosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Página de Ingresos',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}