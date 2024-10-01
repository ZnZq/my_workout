import 'package:flutter/material.dart';

enum ProgressStatus {
  planned,
  inProgress,
  completed,
}

extension ProgressStatusExtension on ProgressStatus {
  IconData get icon {
    switch (this) {
      case ProgressStatus.planned:
        return Icons.more_horiz;
      case ProgressStatus.inProgress:
        return Icons.play_arrow;
      case ProgressStatus.completed:
        return Icons.done;
    }
  }

  Color get color {
    switch (this) {
      case ProgressStatus.planned:
        return Colors.blue.shade400;
      case ProgressStatus.inProgress:
        return Colors.orange.shade400;
      case ProgressStatus.completed:
        return Colors.green.shade400;
    }
  }
}
