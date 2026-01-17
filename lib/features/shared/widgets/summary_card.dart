import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Widget content;

  const SummaryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Color de fondo
              Container(color: backgroundColor),

              // Diseño de fondo circular
              Positioned(
                top: -40,
                right: -40,
                child: _buildCircle(140),
              ),
              Positioned(
                top: 40,
                left: -30,
                child: _buildCircle(80),
              ),
              Positioned(
                bottom: -30,
                right: 40,
                child: _buildCircle(100),
              ),

              // Contenido de la tarjeta
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16
                          ),
                        ),
                        IconContainer(
                          icon: icon,
                          color: Colors.white,
                          size: 26,
                        ),
                      ],
                    ),
                    content,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(255, 255, 255, 0.1),
      ),
    );
  }
}