import 'package:flutter/material.dart';

class TextInputDialog extends StatelessWidget {
  final String title;
  late final String cancelText;
  late final String saveText;
  late final String text;

  late final TextEditingController controller;

  TextInputDialog({
    super.key,
    required this.title,
    String? text,
    String? cancelText,
    String? saveText,
  }) {
    controller = TextEditingController(text: text);

    this.text = text ?? '';
    this.cancelText = cancelText ?? 'Cancel';
    this.saveText = saveText ?? 'Save';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text);
          },
          child: Text(saveText),
        ),
      ],
    );
  }
}
