import 'package:flutter/material.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class ErrorDialog extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onConfirm;

  const ErrorDialog({
    super.key,
    required this.message,
    this.title,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'تنبيه',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getSanitizedMessage(message),
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryEmerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'حسناً',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSanitizedMessage(String msg) {
    // 1. Remove common prefixes
    String sanitized = msg
        .replaceAll(RegExp(r'Exception:\s*', caseSensitive: false), '')
        .replaceAll(
          RegExp(r'Failed to play audio:\s*', caseSensitive: false),
          '',
        )
        .replaceAll(
          RegExp(r'Missing Plugin Exception\(.*?\)', caseSensitive: false),
          '',
        );

    // 2. Extract Arabic part
    final arabicRegex = RegExp(r'[\u0600-\u06FF]+');
    if (sanitized.contains(arabicRegex)) {
      if (msg.contains("لا يوجد اتصال بالإنترنت")) {
        return "لا يوجد اتصال بالإنترنت ولم يتم تحميل هذه الآية مسبقاً.";
      }

      // Clean up lines that contain Arabic
      final linesWithArabic = sanitized
          .split('\n')
          .where((line) => line.contains(arabicRegex))
          .map((line) => line.trim());

      if (linesWithArabic.isNotEmpty) {
        return linesWithArabic.join(' ');
      }
    }

    // 3. Fallback
    if (!sanitized.contains(arabicRegex)) {
      return "عذراً، حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.";
    }

    return sanitized.trim();
  }

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) =>
          ErrorDialog(message: message, title: title, onConfirm: onConfirm),
    );
  }
}
