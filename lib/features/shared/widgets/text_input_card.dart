import 'package:control_financiero/core/formatters/note_input_formatter.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class   TextInputCard extends StatelessWidget {
  final TextEditingController textController;
  final String? placeholder;
  final IconData? iconData;
  final Color? iconColor;

  const TextInputCard({super.key,
  required this.textController,
  this.placeholder,
  this.iconData,
  this.iconColor
  });

  @override
  Widget build(BuildContext context) {
    final [r, g, b] = getRGBFromColor(iconColor ?? Colors.grey);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Categoria
        if (iconColor != null && iconData != null)
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(r, g, b, 0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              iconData,
              size: 22,
              color: iconColor ?? Colors.grey,
            ),
          ),

        const SizedBox(width: 3),
        Expanded(
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
              hintText: placeholder,
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
