import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final int counter;
  final Widget child;

  const BadgeWidget({super.key, required this.counter, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (counter > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Transform.translate(
              offset: const Offset(6, -6),
              child: _BadgeCounter(count: counter),
            ),
          ),
      ],
    );
  }
}

class _BadgeCounter extends StatelessWidget {
  final int count;

  const _BadgeCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
