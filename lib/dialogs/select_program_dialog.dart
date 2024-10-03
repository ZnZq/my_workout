import 'package:flutter/material.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/storage/storage.dart';

class SelectProgramDialog extends StatelessWidget {
  final Widget? firstItem;

  const SelectProgramDialog({super.key, this.firstItem});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select program'),
      content: SizedBox(
        height: 300,
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (firstItem != null) firstItem!,
              for (final program in Storage.programStorage.items)
                _buildProgramCard(context, program),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildProgramCard(BuildContext context, Program program) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        title: Text(program.title),
        subtitle:
            program.description.isNotEmpty ? Text(program.description) : null,
        onTap: () {
          Navigator.of(context).pop(program);
        },
      ),
    );
  }
}
