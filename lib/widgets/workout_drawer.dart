import 'package:flutter/material.dart';
import 'package:my_workout/pages/activity/actvities_page.dart';
import 'package:my_workout/pages/program/programs_page.dart';

class WorkoutDrawer extends StatelessWidget {
  const WorkoutDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('Activity'),
            onTap: () {
              Navigator.of(context).restorablePushNamed(ActvitiesPage.route);
            },
          ),
          ListTile(
            title: const Text('Program'),
            onTap: () {
              Navigator.of(context).restorablePushNamed(ProgramsPage.route);
            },
          ),
        ],
      ),
    );
  }
}
