import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textOffset;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoRotation = Tween(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(_textController);

    _textOffset = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF195DE6);
    const background = Color(0xFFFAFBFC);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          /// Fondo decorativo
          Positioned.fill(
            child: Stack(
              children: [
                _blurCircle(
                  alignment: Alignment.topLeft,
                  color: primary.withOpacity(0.1),
                  size: 300,
                ),
                _blurCircle(
                  alignment: Alignment.bottomRight,
                  color: primary.withOpacity(0.05),
                  size: 350,
                ),
              ],
            ),
          ),

          /// Contenido central
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, child) {
                    return Transform.rotate(
                      angle: _logoRotation.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        'assets/icons/app_prod_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SlideTransition(
                  position: _textOffset,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: const Text(
                      "Mi Presupuesto",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Indicador inferior
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: _LoadingDots(),
          ),
        ],
      ),
    );
  }

  Widget _blurCircle({
    required Alignment alignment,
    required Color color,
    required double size,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF195DE6);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        int active = (_controller.value * 3).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: primary.withOpacity(i == active ? 1 : 0.3),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
