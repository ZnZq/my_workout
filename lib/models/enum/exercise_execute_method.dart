import 'package:flutter/material.dart';
import 'package:my_workout/data.dart';

enum ExerciseExecuteMethod {
  weight,
  cardio,
}

extension ExerciseExecuteMethodExtension on ExerciseExecuteMethod {
  IconData get icon {
    switch (this) {
      case ExerciseExecuteMethod.weight:
        return ui.stat.weight.icon;
      case ExerciseExecuteMethod.cardio:
        return ui.stat.cardio.icon;
    }
  }

  Color get color {
    switch (this) {
      case ExerciseExecuteMethod.weight:
        return ui.stat.weight.color;
      case ExerciseExecuteMethod.cardio:
        return ui.stat.cardio.color;
    }
  }
}
