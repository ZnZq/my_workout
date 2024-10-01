import 'package:flutter/material.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/storage/storage.dart';

class SelectProgramDialog extends StatelessWidget {
  const SelectProgramDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select program'),
      content: SizedBox(
        height: 300,
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: Storage.programStorage.items.length,
          itemBuilder: (context, index) {
            final program = Storage.programStorage.items[index];
            return _buildProgramCard(context, program, index);
          },
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

  Widget _buildProgramCard(BuildContext context, Program program, int index) {
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
