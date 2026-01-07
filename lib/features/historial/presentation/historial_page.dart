import 'package:flutter/material.dart';

class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Página de Historial',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}