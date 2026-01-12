import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:flutter/material.dart';

class TipoMovimientoSelector extends StatefulWidget {
  final TipoMovimiento tipoMovimiento;
  final ValueChanged<TipoMovimiento>? onChanged;
  
  const TipoMovimientoSelector({
    super.key, this.tipoMovimiento = TipoMovimiento.gasto,
    this.onChanged
  });

  @override
  State<TipoMovimientoSelector> createState() => _TipoMovimientoSelectorState();
}

class _TipoMovimientoSelectorState extends State<TipoMovimientoSelector> {
  late TipoMovimiento tipoMovimiento;
  double borderRadiusValue = 10;

  @override
  void initState() {
    super.initState();
    tipoMovimiento = widget.tipoMovimiento;
  }

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
            selected: tipoMovimiento == TipoMovimiento.gasto,
            color: Colors.red,
            onTap: () {
              setState(() {
                tipoMovimiento = TipoMovimiento.gasto;
              });
              widget.onChanged?.call(TipoMovimiento.gasto);
            },
          ),
          _buildOption(
            text: 'Ingreso',
            selected: tipoMovimiento == TipoMovimiento.ingreso,
            color: Colors.green,
            onTap: () {
              setState(() {
                tipoMovimiento = TipoMovimiento.ingreso;
              });
              widget.onChanged?.call(TipoMovimiento.ingreso);
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
