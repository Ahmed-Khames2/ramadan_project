import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class ExpandableHadithBox extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const ExpandableHadithBox({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  State<ExpandableHadithBox> createState() => _ExpandableHadithBoxState();
}

class _ExpandableHadithBoxState extends State<ExpandableHadithBox> {
  bool _isExpanded = false;
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLong = widget.content.length > 300;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 22),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    fontFamily: 'Cairo',
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.content));
                    setState(() => _isCopied = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isCopied = false);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isCopied
                          ? widget.color.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isCopied) ...[
                          const Text(
                            'تم النسخ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Icon(
                          _isCopied
                              ? Icons.check_circle_outline_rounded
                              : Icons.copy_rounded,
                          size: 20,
                          color: widget.color,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  widget.content,
                  textAlign: TextAlign.justify,
                  maxLines: (isLong && !_isExpanded) ? 6 : null,
                  overflow: (isLong && !_isExpanded) ? TextOverflow.fade : null,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    height: 1.8,
                    fontFamily: 'Cairo',
                  ),
                ),
                if (isLong)
                  TextButton.icon(
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    icon: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: widget.color,
                    ),
                    label: Text(
                      _isExpanded ? 'عرض أقل' : 'عرض المزيد',
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
