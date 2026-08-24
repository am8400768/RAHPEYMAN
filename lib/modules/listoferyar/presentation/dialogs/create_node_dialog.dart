
import 'package:flutter/material.dart';

import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_typography.dart';

class CreateNodeDialog extends StatefulWidget {
  const CreateNodeDialog({
    super.key,
    required this.title,
    this.initialName = '',
    this.helperText,
  });

  final String title;
  final String initialName;
  final String? helperText;

  @override
  State<CreateNodeDialog> createState() => _CreateNodeDialogState();
}

class _CreateNodeDialogState extends State<CreateNodeDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(
          widget.title,
          style: ListoferyarTypography.sectionTitle,
        ),
        content: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          style: ListoferyarTypography.bodyText,
          decoration: InputDecoration(
            labelText: 'نام بخش *',
            hintText: 'مثلاً فونداسیون',
            prefixIcon: const Icon(
              Icons.account_tree_rounded,
              color: ListoferyarColors.primary,
            ),
            helperText: widget.helperText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.add_rounded),
            label: const Text('تأیید'),
          ),
        ],
      ),
    );
  }
}
