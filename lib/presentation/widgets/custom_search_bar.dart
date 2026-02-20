import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'ابحث هنا...',
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? theme.colorScheme.secondary
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : theme.colorScheme.secondary.withValues(alpha: 0.1)),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? theme.colorScheme.secondary.withValues(alpha: 0.15)
                : (isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.04)),
            blurRadius: _isFocused ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 16,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          prefixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onClear();
                  },
                )
              : Icon(
                  Icons.search_rounded,
                  color: _isFocused
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
