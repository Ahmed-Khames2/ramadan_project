import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/hadith.dart';

class HadithDetailPage extends StatelessWidget {
  final Hadith hadith;

  const HadithDetailPage({super.key, required this.hadith});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: hadith.textArabic)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ نص الحديث بنجاح'),
          backgroundColor: AppTheme.primaryEmerald,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الحديث ${hadith.idInBook}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'نسخ الحديث',
            onPressed: () => _copyToClipboard(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 20),
            tooltip: 'مشاركة',
            onPressed: () {
              Share.share(
                '${hadith.textArabic}\n\n[ ${hadith.bookTitle} - ${hadith.chapterTitle} ]\n\nحمل تطبيق "زاد":\nhttps://drive.google.com/drive/folders/1OoGk397Kb6sUy5S-qDw8A4EVGK6K0Lhc?usp=drive_link',
              );
            },
          ),
        ],
      ),
      body: DecorativeBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Focused Reading Container
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  border: Border.all(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Ornament
                    Icon(
                      FontAwesomeIcons.quoteRight,
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                      size: 24,
                    ),
                    const SizedBox(height: AppTheme.spacing6),
                    // Hadith Text
                    SelectableText(
                      hadith.textArabic,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        height: 2.0,
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                        wordSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing6),
                    // Bottom Ornament & Metadata
                    const OrnamentalDivider(),
                    const SizedBox(height: AppTheme.spacing6),
                    // Metadata
                    Text(
                      hadith.chapterTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryEmerald,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      hadith.bookTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    // Quick Action Button
                    ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(context),
                      icon: const Icon(Icons.copy_all_rounded, size: 18),
                      label: const Text('نسخ الحديث بالكامل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryEmerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing6,
                          vertical: AppTheme.spacing3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
            ],
          ),
        ),
      ),
    );
  }
}
