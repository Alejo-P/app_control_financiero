import 'package:flutter/material.dart';

class MovimientoSearchPage extends StatefulWidget {
  const MovimientoSearchPage({super.key});

  @override
  State<MovimientoSearchPage> createState() => _MovimientoSearchPageState();
}

class _MovimientoSearchPageState extends State<MovimientoSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Movimiento'),
      ),
      body: const Center(
        child: Text('Aquí puedes buscar movimientos.'),
      ),
    );
  }
}