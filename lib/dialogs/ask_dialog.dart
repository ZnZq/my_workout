import 'package:flutter/material.dart';

class AskDialog extends StatelessWidget {
  final String question;
  final Map<String, dynamic> options;

  const AskDialog({super.key, required this.question, required this.options});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(question),
      actions: [
        for (var entry in options.entries)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(entry.value);
            },
            child: Text(entry.key),
          ),
      ],
    );
  }
}
