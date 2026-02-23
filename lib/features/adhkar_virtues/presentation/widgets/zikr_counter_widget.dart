import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class ZikrCounterWidget extends StatefulWidget {
  final int targetCount;
  final String countDescription;
  final Color color;

  const ZikrCounterWidget({
    super.key,
    required this.targetCount,
    required this.countDescription,
    required this.color,
  });

  @override
  State<ZikrCounterWidget> createState() => _ZikrCounterWidgetState();
}

class _ZikrCounterWidgetState extends State<ZikrCounterWidget>
    with SingleTickerProviderStateMixin {
  int _currentCount = 0;
  bool _isCompleted = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _increment() {
    if (_isCompleted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _currentCount++;
      if (_currentCount >= widget.targetCount) {
        _isCompleted = true;
        HapticFeedback.heavyImpact();
      }
    });
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentCount = 0;
      _isCompleted = false;
    });
  }

  double get _progress => widget.targetCount > 0
      ? (_currentCount / widget.targetCount).clamp(0.0, 1.0)
      : 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _isCompleted ? Colors.green : widget.color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      padding: const EdgeInsets.all(AppTheme.spacing6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.15 : 0.08),
            color.withValues(alpha: isDark ? 0.05 : 0.02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.loop_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                _isCompleted ? 'أحسنت! تم الذكر ✓' : 'عداد الذكر',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing6),

          // Circular Progress + Tap Area
          GestureDetector(
            onTap: _increment,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isCompleted ? 1.0 : _pulseAnimation.value,
                  child: child,
                );
              },
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 10,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                    // Progress circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        color: color,
                      ),
                    ),
                    // Center content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: _isCompleted
                              ? Icon(
                                  Icons.check_rounded,
                                  key: const ValueKey('check'),
                                  color: Colors.green,
                                  size: 48,
                                )
                              : Text(
                                  '$_currentCount',
                                  key: ValueKey(_currentCount),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                        ),
                        Text(
                          'من ${widget.targetCount}',
                          style: TextStyle(
                            color: color.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacing4),

          // Tap instruction
          AnimatedOpacity(
            opacity: _isCompleted ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              'اضغط للتسبيح',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
            ),
          ),

          // Count badge
          if (widget.countDescription.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.countDescription,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],

          const SizedBox(height: AppTheme.spacing4),

          // Reset button
          TextButton.icon(
            onPressed: _reset,
            icon: Icon(
              Icons.refresh_rounded,
              size: 16,
              color: color.withValues(alpha: 0.6),
            ),
            label: Text(
              'إعادة',
              style: TextStyle(
                color: color.withValues(alpha: 0.6),
                fontFamily: 'Cairo',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
