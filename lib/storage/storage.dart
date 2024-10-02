import 'dart:convert';
import 'dart:io';
import 'package:my_workout/models/activity.dart';
import 'package:my_workout/storage/activity_storage.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/foundation.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/storage/program_storage.dart';
import 'package:path_provider/path_provider.dart';

class Storage {
  static late final ProgramStorage programStorage;
  static late final ActivityStorage activityStorage;

  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> get programPath async {
    final path = await localPath;
    return p.join(path, 'programs.json');
  }

  static Future<String> get activityPath async {
    final path = await localPath;
    return p.join(path, 'activities.json');
  }

  static Future<void> initialize() async {
    final programs = await readPrograms();
    final activities = await readActivities();

    programStorage = ProgramStorage(programs)..addListener(_onSavePrograms);
    activityStorage = ActivityStorage(activities)
      ..addListener(_onSaveActivities);
  }

  static void _onSavePrograms() async {
    final programs = programStorage.items;
    final path = await programPath;

    writeJson(path, programs);
  }

  static void _onSaveActivities() async {
    final activities = activityStorage.items;
    final path = await activityPath;

    writeJson(path, activities);
  }

  static Future<List<Program>> readPrograms() async {
    final path = await programPath;
    final rawPrograms = await readJson<List<dynamic>>(path, []);

    final programs =
        rawPrograms.map((e) => Program.fromJson(e)).cast<Program>().toList();

    return programs;
  }

  static Future<List<Activity>> readActivities() async {
    final path = await activityPath;
    final rawActivities = await readJson<List<dynamic>>(path, []);

    final activities = rawActivities
        .map((e) => Activity.fromJson(e))
        .cast<Activity>()
        .toList();

    return activities;
  }

  static Future<T> readJson<T>(String path, T defaultValue) async {
    try {
      final utf8 = Encoding.getByName("utf-8")!;
      final json = await File(path).readAsString(encoding: utf8);
      final data = jsonDecode(json);

      return data as T;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return defaultValue;
    }
  }

  static Future<void> writeJson(String path, dynamic data) async {
    try {
      final utf8 = Encoding.getByName("utf-8")!;
      final json = jsonEncode(data);

      await File(path).writeAsString(json, encoding: utf8);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
