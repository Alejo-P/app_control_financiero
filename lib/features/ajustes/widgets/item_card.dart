import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final bool value;
  final bool showDeleteButton;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onDelete;

  const ItemCard({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.showDeleteButton = false,
    this.onDelete,
  }) : assert(
         !showDeleteButton || onDelete != null,
         'onDelete debe existir cuando showDeleteButton es true',
       );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: value, onChanged: onChanged),
            if (showDeleteButton)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
