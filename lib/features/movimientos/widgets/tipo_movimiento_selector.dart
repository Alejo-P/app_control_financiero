import 'package:flutter/material.dart';

class TipoMovimientoSelector extends StatefulWidget {
  const TipoMovimientoSelector({super.key});

  @override
  State<TipoMovimientoSelector> createState() =>
      _TipoMovimientoSelectorState();
}

class _TipoMovimientoSelectorState extends State<TipoMovimientoSelector> {
  bool esGasto = true;
  double borderRadiusValue = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadiusValue),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildOption(
            text: 'Gasto',
            selected: esGasto,
            color: Colors.red,
            onTap: () {
              setState(() => esGasto = true);
              debugPrint('Seleccionó Gasto');
            },
          ),
          _buildOption(
            text: 'Ingreso',
            selected: !esGasto,
            color: Colors.green,
            onTap: () {
              setState(() => esGasto = false);
              debugPrint('Seleccionó Ingreso');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String text,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadiusValue),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
