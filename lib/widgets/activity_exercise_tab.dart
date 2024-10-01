import 'package:flutter/material.dart';
import 'package:my_workout/models/activity_exercise.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/widgets/icon_text.dart';

class ActivityExerciseTab extends StatelessWidget {
  final ActivityExercise activityExercise;

  const ActivityExerciseTab({super.key, required this.activityExercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Tab(
        child: IconText(
          text: activityExercise.name,
          icon: activityExercise.executeMethod.icon,
          iconColor: activityExercise.executeMethod.color,
        ),
      ),
    );
  }
}
