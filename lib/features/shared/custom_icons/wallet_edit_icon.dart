import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletEditIcon extends StatelessWidget {
  const WalletEditIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final baseIconSVG =
        '''<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#e3e3e3"><path d="M240-160q-66 0-113-47T80-320v-320q0-66 47-113t113-47h480q66 0 113 47t47 113v320q0 66-47 113t-113 47H240Zm0-480h480q22 0 42 5t38 16v-21q0-33-23.5-56.5T720-720H240q-33 0-56.5 23.5T160-640v21q18-11 38-16t42-5Zm-74 130 445 108q9 2 18 0t17-8l139-116q-11-15-28-24.5t-37-9.5H240q-26 0-45.5 13.5T166-510Z"/></svg>''';

    final pencilIconSVG =
        '''<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#e3e3e3"><path d="M200-200h57l391-391-57-57-391 391v57Zm-80 80v-170l528-527q12-11 26.5-17t30.5-6q16 0 31 6t26 18l55 56q12 11 17.5 26t5.5 30q0 16-5.5 30.5T817-647L290-120H120Z"/></svg>''';

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

          // Icono lápiz (más pequeño, esquina inferior derecha)
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
                pencilIconSVG,
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
