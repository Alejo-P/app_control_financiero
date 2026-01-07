import 'package:flutter/material.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double spentAmount;
  final IconData icon;

  const BudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.spentAmount,
    this.icon = Icons.pie_chart,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalBudget;
    final spent = spentAmount;
    final available = total - spent;
    final percent = spent / total;
    // use percent to set the progress indicator's value programmatically
    final progressValue = percent.clamp(0.0, 1.0);

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
              Container(color: Colors.blue),

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
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Total Presupuestado',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gastado: \$${spent.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.white70)
                            ),
                            Text(
                              '${(percent * 100).toStringAsFixed(0)}%',
                              style: TextStyle(color: Colors.white70)
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Disponible',
                                style: TextStyle(color: Colors.white70)),
                            Text(
                              '\$${available.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]
                )
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
