import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final bool showDescription;
  final _formKey = GlobalKey<FormState>();

  InfoDialog(
      {super.key,
      String title = '',
      String description = '',
      this.showDescription = true}) {
    titleController = TextEditingController(text: title);
    descriptionController = TextEditingController(text: description);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Info'),
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
            if (showDescription)
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
      if (showDescription) 'description': descriptionController.text,
    });
  }
}
