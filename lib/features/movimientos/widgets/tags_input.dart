// ignore_for_file: deprecated_member_use

import 'package:control_financiero/features/etiquetas/models/etiqueta.dart';
import 'package:control_financiero/features/shared/widgets/input_card.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:flutter/material.dart';

class TagsInput extends StatefulWidget {
  final StringTagController tagsController;
  final String? placeholder;
  final bool isEditable;
  final List<Etiqueta> tags;
  final ValueChanged<String>? onTagAdded;
  final ValueChanged<String>? onTagRemoved;
  final String? Function(String?)? validator;

  const TagsInput({
    super.key,
    required this.tagsController,
    this.isEditable = true,
    this.placeholder,
    this.tags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.validator,
  });

  @override
  State<TagsInput> createState() => _TagsInputState();
}

class _TagsInputState extends State<TagsInput> {
  late int _lastTagCount;

  @override
  void initState() {
    super.initState();

    _lastTagCount = widget.tagsController.getTags?.length ?? 0;

    widget.tagsController.addListener(_onTagsChanged);
  }

  void _onTagsChanged() {
    final tags = widget.tagsController.getTags ?? [];

    if (tags.length > _lastTagCount) {
      widget.onTagAdded?.call(tags.last);
    }

    _lastTagCount = tags.length;
  }

  @override
  void dispose() {
    widget.tagsController.removeListener(_onTagsChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TagsInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tags != widget.tags) {
      widget.tagsController.clearTags();
      for (final tag in widget.tags) {
        widget.tagsController.addTag(tag.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TextFieldTags<String>(
      textfieldTagsController: widget.tagsController,
      initialTags: widget.tags.map((e) => e.name).toList(),
      textSeparators: const [' ', ','],
      validator: widget.validator,
      inputFieldBuilder: (context, inputFieldValues) {
        return InputCard(
          icon: Icons.label_outline,
          iconColor: theme.colorScheme.primary,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Chips
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: inputFieldValues.tags.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: inputFieldValues.tags.map((tag) {
                            final etiqueta = widget.tags.firstWhere(
                              (e) => e.name == tag,
                              orElse: () => Etiqueta(name: tag, colorValue: 0),
                            );

                            return InputChip(
                              label: Text(
                                tag,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: etiqueta.color,
                              deleteIcon: const Icon(Icons.close, size: 16),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              onDeleted: () {
                                widget.onTagRemoved?.call(tag);
                                inputFieldValues.onTagRemoved(tag);
                              },
                            );
                          }).toList(),
                        ),
                      ),
              ),

              /// Campo de texto
              TextFormField(
                controller: inputFieldValues.textEditingController,
                focusNode: inputFieldValues.focusNode,
                onChanged: inputFieldValues.onTagChanged,
                onFieldSubmitted: (value) {
                  inputFieldValues.onTagSubmitted(value);
                },
                validator: widget.validator,
                enabled: widget.isEditable,
                maxLength: 10,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: widget.placeholder,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  counterText: '', // Oculta el contador predeterminado
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
