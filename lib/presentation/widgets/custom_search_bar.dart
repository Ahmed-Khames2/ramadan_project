import 'package:flutter/cupertino.dart';
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
    this.showBorder = true,
    this.showShadow = true,
  });

  final bool showBorder;
  final bool showShadow;

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
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: widget.showBorder
            ? Border.all(
                color: _isFocused
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.1),
                width: _isFocused ? 1.5 : 1,
              )
            : null,
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: (isDark ? Colors.black : theme.colorScheme.primary)
                      .withOpacity(_isFocused ? 0.15 : 0.05),
                  blurRadius: _isFocused ? 15 : 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: CupertinoSearchTextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        placeholder: widget.hintText,
        backgroundColor: Colors.transparent, // Using parent decoration
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        placeholderStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.35),
          fontSize: 14,
          fontFamily: 'Cairo',
        ),
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 16,
          fontFamily: 'Cairo',
        ),
        itemColor: theme.colorScheme.primary,
        itemSize: 20,
        prefixInsets: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
        suffixInsets: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
        onSuffixTap: () {
          widget.controller.clear();
          widget.onClear();
        },
      ),
    );
  }
}
