import 'package:flutter/material.dart';

class RecordatorioFormPage extends StatefulWidget {
  const RecordatorioFormPage({super.key});

  @override
  State<RecordatorioFormPage> createState() => _RecordatorioFormPageState();
}

class _RecordatorioFormPageState extends State<RecordatorioFormPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear recordatorio')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        child: Center(
          child: Text('Formulario aqui!!!'),
        ),
      ),
    );
  }
}
