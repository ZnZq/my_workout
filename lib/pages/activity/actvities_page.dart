import 'package:flutter/material.dart';
import 'package:my_workout/dialogs/select_program_dialog.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/pages/activity/activity_page.dart';
import 'package:my_workout/widgets/workout_app_bar.dart';
import 'package:my_workout/widgets/workout_drawer.dart';

class ActvitiesPage extends StatelessWidget {
  static const route = '/activities';

  const ActvitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: WorkoutDrawer(),
      appBar: WorkoutAppBar(
        title: const Text('Activities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addActivity(context);
            },
          ),
        ],
      ),
    );
  }

  void _addActivity(BuildContext context) async {
    final program = await showDialog<Program>(
      context: context,
      builder: (context) {
        return const SelectProgramDialog();
      },
    );

    if (program == null || !context.mounted) {
      return;
    }

    Navigator.of(context).pushNamed(ActivityPage.route, arguments: program);
  }
}
