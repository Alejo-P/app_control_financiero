// ignore_for_file: deprecated_member_use

import 'package:control_financiero/features/etiquetas/models/etiqueta.dart';
import 'package:control_financiero/features/shared/widgets/input_card.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:flutter/material.dart';

class TagsInput extends StatefulWidget {
  final String? placeholder;
  final bool isEditable;
  final int maxTags;
  final List<Etiqueta> tags;
  final ValueChanged<String>? onTagAdded;
  final ValueChanged<String>? onTagRemoved;
  final String? Function(String?)? validator;

  const TagsInput({
    super.key,
    this.isEditable = true,
    this.maxTags = 5,
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
  late final StringTagController _tagsController;
  late int _lastTagCount;

  @override
  void initState() {
    super.initState();

    _tagsController = StringTagController();
    _lastTagCount = widget.tags.length;

    _tagsController.addListener(_onTagsChanged);
  }

  void _onTagsChanged() {
    final tags = _tagsController.getTags ?? [];

    if (tags.length > _lastTagCount) {
      widget.onTagAdded?.call(tags.last);
    }

    _lastTagCount = tags.length;
  }

  @override
  void dispose() {
    _tagsController.removeListener(_onTagsChanged);
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final tagsListLength = _tagsController.getTags?.length ?? widget.tags.length;
    final canAddTags = widget.isEditable && tagsListLength < widget.maxTags;
    String? validateTag(String? tag) {
      if (tag == null || tag.trim().isEmpty) return null;

      if ((_tagsController.getTags?.length ?? widget.tags.length) >=
          widget.maxTags) {
        return 'No puedes agregar más de ${widget.maxTags} etiquetas';
      }

      return widget.validator?.call(tag);
    }

    return TextFieldTags<String>(
      textfieldTagsController: _tagsController,
      initialTags: widget.tags.map((e) => e.name).toList(),
      textSeparators: const [' ', ','],
      validator: validateTag,
      inputFieldBuilder: (context, inputFieldValues) {
        return InputCard(
          icon: Icons.label_outline,
          iconColor: theme.colorScheme.primary,
          trailing: Text(
            '$tagsListLength/${widget.maxTags}',
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
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
                              deleteIcon: widget.isEditable
                                  ? const Icon(Icons.close, size: 16)
                                  : null,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              onDeleted: widget.isEditable
                                  ? () {
                                      widget.onTagRemoved?.call(tag);
                                      inputFieldValues.onTagRemoved(tag);
                                    }
                                  : null,
                            );
                          }).toList(),
                        ),
                      ),
              ),

              /// Campo de texto
              TextFormField(
                controller: inputFieldValues.textEditingController,
                focusNode: inputFieldValues.focusNode,
                onChanged: canAddTags ? inputFieldValues.onTagChanged : null,
                onFieldSubmitted: (value) {
                  if (canAddTags) {
                    inputFieldValues.onTagSubmitted(value);
                  }
                },
                validator: validateTag,
                enabled: canAddTags,
                maxLength: 10,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: widget.placeholder ??
                      (canAddTags
                          ? 'Agregar etiquetas...'
                          : 'No puedes agregar etiquetas'),
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
