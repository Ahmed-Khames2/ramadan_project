import 'package:flutter/material.dart';
import '../widgets/hadith_content_view.dart';
import '../../domain/entities/hadith.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';

class HadithDetailsPage extends StatelessWidget {
  final Hadith hadith;

  const HadithDetailsPage({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hadith.title)),
      body: DecorativeBackground(child: HadithContentView(hadith: hadith)),
    );
  }
}
