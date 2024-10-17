import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_workout/models/reportable.dart';
import 'package:my_workout/widgets/icon_text.dart';
import 'package:share_plus/share_plus.dart';

class ReportPage extends StatelessWidget {
  static const String route = '/report';

  final Reportable reportable;

  const ReportPage({super.key, required this.reportable});

  @override
  Widget build(BuildContext context) {
    final report = reportable.generateReport();

    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'copy',
                  child: IconText(
                    icon: Icons.copy,
                    text: 'Copy',
                    iconColor: Colors.white,
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: IconText(
                    icon: Icons.share,
                    text: 'Share',
                    iconColor: Colors.white,
                  ),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 'copy':
                  _copy(context, report);
                  break;
                case 'share':
                  _share(report);
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(report),
        ),
      ),
    );
  }

  void _copy(BuildContext context, String report) async {
    await Clipboard.setData(ClipboardData(text: report));

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Copied")));
    }
  }

  void _share(String report) {
    Share.share(report);
  }
}
