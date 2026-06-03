import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
    final String title;
    final bool value;
    final ValueChanged<bool> onChanged;

    const ItemCard({
        super.key,
        required this.title,
        required this.value,
        required this.onChanged,
    });

    @override
    Widget build(BuildContext context) {
        return Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Switch(value: value, onChanged: onChanged),
            ],
            ),
        ),
        );
    }
}
