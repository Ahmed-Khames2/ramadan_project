import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/hadith.dart';

class HadithDetailPage extends StatelessWidget {
  final Hadith hadith;

  const HadithDetailPage({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حديث رقم ${hadith.idInBook}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                '${hadith.textArabic}\n\n[ ${hadith.bookTitle} - ${hadith.chapterTitle} ]',
              );
            },
          ),
        ],
      ),
      body: DecorativeBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  side: BorderSide(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing6),
                  child: Column(
                    children: [
                      Text(
                        hadith.textArabic,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.8,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing6),
                      const Divider(),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        hadith.chapterTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryEmerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      Text(
                        hadith.bookTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
