import 'package:flutter/material.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/pages/program/program_page.dart';
import 'package:my_workout/storage/storage.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/workout_app_bar.dart';
import 'package:my_workout/widgets/workout_drawer.dart';

class ProgramsPage extends StatelessWidget {
  static const route = '/programs';

  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const WorkoutDrawer(),
      appBar: WorkoutAppBar(
        title: const Text('Programs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _openProgram(context, Program(title: 'New program'));
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Storage.programStorage,
        builder: (context, child) {
          return ListView.builder(
            itemCount: Storage.programStorage.items.length,
            itemBuilder: (context, index) {
              final program = Storage.programStorage.items[index];
              return _buildProgramCard(context, program, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context, Program program, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Dismissible(
          key: ValueKey(program.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            Storage.programStorage.remove(program.id);
          },
          confirmDismiss: (direction) async {
            return await askDialog(
              context,
              'Are you sure you want to delete ${program.title}?',
            );
          },
          child: ListTile(
            title: Text(program.title),
            subtitle: program.description.isNotEmpty
                ? Text(program.description)
                : null,
            onTap: () {
              _openProgram(context, program);
            },
          ),
        ),
      ),
    );
  }

  void _openProgram(BuildContext context, Program program) {
    Navigator.of(context)
        .restorablePushNamed(ProgramPage.route, arguments: program.toJson());
  }
}
