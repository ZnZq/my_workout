import 'package:flutter/material.dart';
import 'package:my_workout/models/activity.dart';

class ActivityReportPage extends StatelessWidget {
  static const String route = '/activity_report';

  final Activity activity;

  const ActivityReportPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(activity.generateReport()),
        ),
      ),
    );
  }
}
