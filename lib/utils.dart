import 'package:flutter/material.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/dialogs/goal/goal_dialog.dart';
import 'package:my_workout/dialogs/info_dialog.dart';
import 'package:my_workout/dialogs/text_input_dialog.dart';
import 'package:my_workout/dialogs/ask_dialog.dart';
import 'package:my_workout/models/goal.dart';
import 'package:vibration/vibration.dart';

extension MapExtension<K, V> on Map<K, V> {
  getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key] : defaultValue;
  }
}

Future<void> vibrate({
  int duration = 500,
  List<int> pattern = const [],
  int repeat = -1,
  List<int> intensities = const [],
  int amplitude = -1,
}) async {
  if (!hasVibrator) {
    return;
  }

  await Vibration.vibrate(
      duration: duration,
      pattern: pattern,
      repeat: repeat,
      intensities: intensities,
      amplitude: amplitude);
}

Future<Map<String, String>?> infoDialog(
  BuildContext context,
  String title, {
  String description = '',
  bool showDescription = true,
}) async {
  var result = await showDialog(
    context: context,
    builder: (context) {
      return InfoDialog(
          title: title,
          description: description,
          showDescription: showDescription);
    },
  );

  return result;
}

Future<String?> textInputDialog(
  BuildContext context,
  String title, {
  String? text,
  String? cancelText,
  String? saveText,
}) async {
  var result = await showDialog(
    context: context,
    builder: (context) {
      return TextInputDialog(
        title: title,
        text: text,
        cancelText: cancelText,
        saveText: saveText,
      );
    },
  );

  return result;
}

Color darken(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var f = 1 - percent / 100;
  return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
      (c.blue * f).round());
}

Color lighten(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var p = percent / 100;
  return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).round(),
      c.green + ((255 - c.green) * p).round(),
      c.blue + ((255 - c.blue) * p).round());
}

Future<dynamic> askDialog(
  BuildContext context,
  String question, {
  Map<String, dynamic> options = const {
    'No': false,
    'Yes': true,
  },
}) async {
  var result = await showDialog(
    context: context,
    builder: (context) => AskDialog(question: question, options: options),
  );

  return result;
}

Future<Goal?> goalDialog(BuildContext context, Goal goal) async {
  var result = await showDialog(
    context: context,
    builder: (context) => GoalDialog(goal: goal),
  );

  return result;
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = (duration.inMinutes % 60);
  final seconds = (duration.inSeconds % 60);
  final timeParts = <String>[];
  if (hours != 0) {
    timeParts.add('${hours}h');
  }
  if (minutes != 0) {
    timeParts.add('${minutes}m');
  }
  if (seconds != 0) {
    timeParts.add('${seconds}s');
  }

  if (timeParts.isEmpty) {
    return '0s';
  }

  return timeParts.join(' ');
}
