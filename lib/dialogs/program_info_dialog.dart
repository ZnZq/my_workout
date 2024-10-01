import 'package:flutter/material.dart';

class ProgramInfoDialog extends StatelessWidget {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final _formKey = GlobalKey<FormState>();

  ProgramInfoDialog({super.key, String title = '', String description = ''}) {
    titleController = TextEditingController(text: title);
    descriptionController = TextEditingController(text: description);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Program Info'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              textCapitalization: TextCapitalization.words,
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
              autovalidateMode: AutovalidateMode.always,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter value';
                }
                return null;
              },
            ),
            TextFormField(
              textCapitalization: TextCapitalization.words,
              controller: descriptionController,
              autofocus: false,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _save(context),
          child: Text('Save'),
        ),
      ],
    );
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop({
      'title': titleController.text,
      'description': descriptionController.text,
    });
  }
}
