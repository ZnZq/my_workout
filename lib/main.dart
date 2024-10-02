import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_workout/models/activity.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/pages/activity/activity_page.dart';
import 'package:my_workout/pages/activity/actvities_page.dart';
import 'package:my_workout/pages/main/main_page.dart';
import 'package:my_workout/pages/program/program_page.dart';
import 'package:my_workout/pages/program/programs_page.dart';
import 'package:my_workout/storage/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Storage.initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: kDebugMode,
      initialRoute: MainPage.route,
      theme: ThemeData.dark(),
      routes: {
        MainPage.route: (context) => const MainPage(),
        ProgramsPage.route: (context) => const ProgramsPage(),
        ActvitiesPage.route: (context) => const ActvitiesPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ProgramPage.route) {
          final program = settings.arguments as Program?;
          return MaterialPageRoute<Program?>(
            builder: (context) => ProgramPage(program: program),
          );
        }
        if (settings.name == ActivityPage.route && settings.arguments != null) {
          final activity = settings.arguments as Activity;
          return MaterialPageRoute<Activity?>(
            builder: (context) => ActivityPage(activity: activity),
          );
        }

        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}
