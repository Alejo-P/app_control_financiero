import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class TipoMovimientoSelector extends StatefulWidget {
  final TipoMovimiento tipoMovimiento;
  final ValueChanged<TipoMovimiento>? onChanged;
  final bool isViewOnly;

  const TipoMovimientoSelector({
    super.key,
    required this.tipoMovimiento,
    this.onChanged,
    this.isViewOnly = false,
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
    
    setState(() {
      tipoMovimiento = widget.tipoMovimiento;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColors = theme.colorScheme;
    final [r, g, b] = getRGBFromColor(themeColors.onSurface);

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(borderRadiusValue),
        boxShadow: [BoxShadow(color: Color.fromRGBO(r, g, b, 0.15))],
      ),
      child: Row(
        children: [
          _buildOption(
            text: 'Gasto',
            selected: tipoMovimiento == TipoMovimiento.gasto,
            textColor: Colors.red,
            selectedTextColor: Colors.white,
            color: Colors.red,
            onTap: () {
              if (tipoMovimiento == TipoMovimiento.gasto || widget.isViewOnly) return;

              setState(() {
                tipoMovimiento = TipoMovimiento.gasto;
              });
              widget.onChanged?.call(TipoMovimiento.gasto);
            },
          ),
          _buildOption(
            text: 'Ingreso',
            selected: tipoMovimiento == TipoMovimiento.ingreso,
            textColor: Colors.green,
            selectedTextColor: Colors.white,
            color: Colors.green,
            onTap: () {
              if (tipoMovimiento == TipoMovimiento.ingreso || widget.isViewOnly) return;
              
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
    required Color textColor,
    required Color selectedTextColor,
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
              color: selected ? selectedTextColor : textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
