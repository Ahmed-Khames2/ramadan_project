import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class ExpandableInfoBox extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final bool initiallyExpanded;

  const ExpandableInfoBox({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableInfoBox> createState() => _ExpandableInfoBoxState();
}

class _ExpandableInfoBoxState extends State<ExpandableInfoBox> {
  late bool _isExpanded;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isLong = widget.content.length > 250;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                Icon(widget.icon, color: widget.color, size: 20),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isCopied
                          ? widget.color.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isCopied) ...[
                          const Text(
                            'تم النسخ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Icon(
                          _isCopied
                              ? Icons.check_circle_outline_rounded
                              : Icons.copy_rounded,
                          size: 18,
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
                  maxLines: (isLong && !_isExpanded) ? 5 : null,
                  overflow: (isLong && !_isExpanded) ? TextOverflow.fade : null,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 17,
                    height: 1.7,
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
