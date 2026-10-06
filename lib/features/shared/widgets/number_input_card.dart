import 'package:control_financiero/core/formatters/number_input_formatter.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputCard extends StatefulWidget {
  final TextEditingController textController;
  final String? placeholder;
  final IconData? iconData;
  final Color? iconColor;
  final bool isEditable;
  final int maxLines;
  final int maxLength;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const NumberInputCard({
    super.key,
    required this.textController,
    this.placeholder,
    this.iconData,
    this.iconColor,
    this.isEditable = true,
    this.maxLines = 1,
    this.maxLength = 100,
    this.validator,
    this.inputFormatters,
  });

  @override
  State<NumberInputCard> createState() => _NumberInputCardState();
}

class _NumberInputCardState extends State<NumberInputCard> {
  late FocusNode _focusNode;
  bool isFocused = false;
  int currentLength = 0;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    // Escucha cambios de foco
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });

    // Inicializa contador
    currentLength = widget.textController.text.length;

    // Escucha cambios en el texto para actualizar el contador
    widget.textController.addListener(() {
      setState(() {
        currentLength = widget.textController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Limpia el FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final [r, g, b] = getRGBFromColor(widget.iconColor ?? Colors.grey);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Categoria
        if (widget.iconColor != null && widget.iconData != null)
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(r, g, b, 0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              widget.iconData,
              size: 22,
              color: widget.iconColor ?? Colors.grey,
            ),
          ),

        const SizedBox(width: 3),
        Expanded(
          child: TextFormField(
            controller: widget.textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
              hintText: widget.placeholder,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              counterText: '', // Oculta el contador predeterminado
            ),
            style: const TextStyle(fontSize: 16),
            inputFormatters: widget.inputFormatters ?? [NumberInputFormatter()],
            keyboardType: TextInputType.number,
            expands: false,
            textAlignVertical: TextAlignVertical.top,
            minLines: 1,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength != -1 ? widget.maxLength : null,
            enabled: widget.isEditable,
            validator: widget.validator,
          ),
        ),
        const SizedBox(width: 8),

        // Contador de caracteres
        if (widget.maxLength > 0 && isFocused)
          Text(
            '$currentLength/${widget.maxLength}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
      ],
    );
  }
}
