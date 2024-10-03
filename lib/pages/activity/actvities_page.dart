import 'package:flutter/material.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/dialogs/select_program_dialog.dart';
import 'package:my_workout/models/activity.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/pages/activity/activity_page.dart';
import 'package:my_workout/storage/storage.dart';
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
      body: ListenableBuilder(
        listenable: Storage.activityStorage,
        builder: (context, child) {
          return ListView.builder(
            itemCount: Storage.activityStorage.items.length,
            itemBuilder: (context, index) {
              final activity = Storage.activityStorage.items[index];
              return _buildActivityCard(context, activity, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    Activity activity,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Dismissible(
          key: ValueKey(activity.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            Storage.activityStorage.remove(activity.id);
          },
          child: ListTile(
            title: Text(activity.title),
            subtitle: Text(dateTimeFormat.format(activity.date)),
            leading: CircleAvatar(
              maxRadius: 16,
              backgroundColor: activity.status.color,
              child: Icon(activity.status.icon, size: 16),
            ),
            onTap: () {
              _openActivity(context, activity);
            },
          ),
        ),
      ),
    );
  }

  void _addActivity(BuildContext context) async {
    final program = await showDialog<Program?>(
      context: context,
      builder: (context) {
        return SelectProgramDialog(
          firstItem: Card(
            clipBehavior: Clip.hardEdge,
            color: Colors.green,
            child: ListTile(
              title: Center(child: Text('Without program')),
              onTap: () {
                Navigator.of(context).pop(Program.empty());
              },
            ),
          ),
        );
      },
    );

    if (program == null || !context.mounted) {
      return;
    }

    final activity = Activity.fromProgram(program: program);
    Storage.activityStorage.insertAt(0, activity);

    _openActivity(context, activity);
  }

  void _openActivity(BuildContext context, Activity activity) async {
    final changedActivity = await Navigator.of(context)
        .pushNamed<Activity?>(ActivityPage.route, arguments: activity);
    if (changedActivity == null) {
      return;
    }

    Storage.activityStorage.update(changedActivity);
  }
}
