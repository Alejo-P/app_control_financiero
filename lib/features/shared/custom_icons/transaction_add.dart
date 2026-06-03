import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransactionAddIcon extends StatelessWidget {
  const TransactionAddIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final baseIconSVG =
        '''<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#e3e3e3"><path d="M200-120q-33 0-56.5-23.5T120-200v-560q0-33 23.5-56.5T200-840h560q33 0 56.5 23.5T840-760H520q-71 0-115.5 44.5T360-600v240q0 71 44.5 115.5T520-200h320q0 33-23.5 56.5T760-120H200Zm320-160q-33 0-56.5-23.5T440-360v-240q0-33 23.5-56.5T520-680h280q33 0 56.5 23.5T880-600v240q0 33-23.5 56.5T800-280H520Zm163-157q17-17 17-43t-17-43q-17-17-43-17t-43 17q-17 17-17 43t17 43q17 17 43 17t43-17Z"/></svg>''';

    final addIconSVG =
        '''<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#e3e3e3"><path d="M440-440H240q-17 0-28.5-11.5T200-480q0-17 11.5-28.5T240-520h200v-200q0-17 11.5-28.5T480-760q17 0 28.5 11.5T520-720v200h200q17 0 28.5 11.5T760-480q0 17-11.5 28.5T720-440H520v200q0 17-11.5 28.5T480-200q-17 0-28.5-11.5T440-240v-200Z"/></svg>''';

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          // Icono base (el primero)
          Positioned.fill(
            child: SvgPicture.string(
              baseIconSVG,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          // Icono añadir (más pequeño, esquina inferior derecha)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary, // 🔑 separa visualmente
                shape: BoxShape.circle,
              ),
              //padding: const EdgeInsets.all(2),
              child: SvgPicture.string(
                addIconSVG,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
