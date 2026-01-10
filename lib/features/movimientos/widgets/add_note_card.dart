import 'package:control_financiero/core/formatters/note_input_formatter.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class AddNoteCard extends StatelessWidget {
  final TextEditingController noteController;

  const AddNoteCard({super.key, required this.noteController});

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.grey.shade600;
    final [r, g, b] = getRGBFromColor(iconColor);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Categoria
        Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromRGBO(r, g, b, 0.15),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.edit_note,
            size: 22,
            color: iconColor
          ),
        ),

        const SizedBox(width: 3),
        Expanded(
          child: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
              hintText: 'Agregar una nota (opcional)',
            ),
            style: const TextStyle(fontSize: 16),
            inputFormatters: [
              NoteInputFormatter(),
            ],
          ),
        ),
      ],
    );
  }
}
