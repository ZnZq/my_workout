import 'package:flutter/material.dart';

enum ExerciseExecuteMethod {
  weight,
  cardio,
}

extension ExerciseExecuteMethodExtension on ExerciseExecuteMethod {
  IconData get icon {
    switch (this) {
      case ExerciseExecuteMethod.weight:
        return Icons.fitness_center;
      case ExerciseExecuteMethod.cardio:
        return Icons.monitor_heart;
    }
  }

  Color get color {
    switch (this) {
      case ExerciseExecuteMethod.weight:
        return Colors.blue;
      case ExerciseExecuteMethod.cardio:
        return Colors.green;
    }
  }
}
