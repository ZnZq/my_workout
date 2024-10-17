import 'package:flutter/material.dart';
import 'package:my_workout/widgets/workout_app_bar.dart';
import 'package:my_workout/widgets/workout_drawer.dart';

class MainPage extends StatelessWidget {
  static const route = '/';

  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: WorkoutDrawer(),
      appBar: WorkoutAppBar(
        title: Text('Main page'),
      ),
      body: Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}
