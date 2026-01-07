import 'package:flutter/material.dart';

class TotalBalanceCard extends StatelessWidget {
  final double totalBalance;
  final IconData icon;

  const TotalBalanceCard({
    super.key, 
    required this.totalBalance, 
    required this.icon,
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
              Container(color: Colors.purple),

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Balance Total',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${totalBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '+5.2%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        ),
                        SizedBox(width: 8),
                        Text(
                          'vs. mes anterior',
                          style: TextStyle(color: Colors.white70),
                        )
                      ],
                    ),
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
