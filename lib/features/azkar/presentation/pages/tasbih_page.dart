import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/features/settings/presentation/tasbih_settings_sheet.dart';
import 'package:ramadan_project/presentation/blocs/tasbih_bloc.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage>
    with SingleTickerProviderStateMixin {
  late TasbihBloc _tasbihBloc;
  double _rotationAngle = 0.0;
  double _velocity = 0.0;
  late AnimationController _physicsController;

  // To track bead passing
  int _lastBeadIndex = 0;
  DateTime _lastTapTime = DateTime.now();
  bool _lockBeadPassDetection = false;

  @override
  void initState() {
    super.initState();
    _tasbihBloc = TasbihBloc();
    _physicsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _physicsController.addListener(_handlePhysicsUpdate);
  }

  void _handlePhysicsUpdate() {
    if (_physicsController.isAnimating) {
      // Friction / Deceleration
      final friction = 0.95;
      _velocity *= friction;

      _updateRotation(_velocity * 0.05);

      // Snap logic when slow
      if (_velocity.abs() < 0.01) {
        _physicsController.stop();
        _snapToNearestBead();
      }
    }
  }

  void _snapToNearestBead() {
    final state = _tasbihBloc.state;
    final step = (2 * math.pi) / state.targetCount;

    // Nearest step
    final targetAngle = (_rotationAngle / step).round() * step;

    // Animate to target
    final snapAnimation = Tween<double>(begin: _rotationAngle, end: targetAngle)
        .animate(
          CurvedAnimation(
            parent: _physicsController,
            curve: Curves.easeOutBack,
          ),
        );

    // Reset controller for a short snap animation
    _physicsController.duration = const Duration(milliseconds: 400);
    _physicsController.removeListener(_handlePhysicsUpdate);

    AnimationStatusListener? statusListener;
    statusListener = (status) {
      if (status == AnimationStatus.completed) {
        _physicsController.removeListener(_handlePhysicsUpdate); // Just in case
        _physicsController.addListener(_handlePhysicsUpdate);
        _physicsController.removeStatusListener(statusListener!);
      }
    };

    _physicsController.addStatusListener(statusListener);

    void snapListener() {
      setState(() {
        _rotationAngle = snapAnimation.value;
      });
    }

    _physicsController.addListener(snapListener);
    _physicsController.forward(from: 0.0).then((_) {
      _physicsController.removeListener(snapListener);
      _physicsController.duration = const Duration(milliseconds: 2000);
    });
  }

  void _updateRotation(double delta) {
    setState(() {
      _rotationAngle += delta;
      _detectBeadPass();
    });
  }

  void _detectBeadPass() {
    if (_lockBeadPassDetection) return;

    final state = _tasbihBloc.state;
    final step = (2 * math.pi) / state.targetCount;

    int currentIndex = (_rotationAngle / step).floor();

    if (currentIndex != _lastBeadIndex) {
      if (currentIndex > _lastBeadIndex) {
        // Moving forward
        _tasbihBloc.add(IncrementCount());
        HapticFeedback.selectionClick();
      }
      _lastBeadIndex = currentIndex;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Determine if vertical or horizontal drag is better.
    // Since it's a circle, let's use a combination or just X for simplicity now.
    _updateRotation(details.delta.dx / 120.0);
  }

  void _onPanEnd(DragEndDetails details) {
    _velocity = details.velocity.pixelsPerSecond.dx / 1000.0;
    _physicsController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _physicsController.dispose();
    _tasbihBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _tasbihBloc,
      child: Scaffold(
        body: DecorativeBackground(
          child: BlocListener<TasbihBloc, TasbihState>(
            listenWhen: (previous, current) =>
                previous.rounds != current.rounds,
            listener: (context, state) {
              if (state.rounds > 0) {
                // Round completion feedback (Vibration removed)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'أتممت دورة كاملة بنجاح!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppTheme.primaryEmerald,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: BlocBuilder<TasbihBloc, TasbihState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    const OrnamentalDivider(),
                    const Spacer(flex: 2),
                    _buildCounterDisplay(state),
                    const Spacer(flex: 2),
                    _buildTasbihRenderer(context, state),
                    const Spacer(flex: 3),
                    _buildControls(context),
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const IslamicBackButton(),
          Text(
            'المسبحة الإلكترونية',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance the back button
        ],
      ),
    );
  }

  Widget _buildCounterDisplay(TasbihState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              '${state.count}',
              key: ValueKey(state.count),
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                height: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'الدورة: ${state.rounds}',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasbihRenderer(BuildContext context, TasbihState state) {
    return Expanded(
      flex: 10,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTapDown: (_) {
          final now = DateTime.now();
          if (now.difference(_lastTapTime) <
              const Duration(milliseconds: 600)) {
            return; // Debounce
          }
          _lastTapTime = now;

          // Lock automated detection briefly to avoid double-counting the tap animation
          _lockBeadPassDetection = true;
          _tasbihBloc.add(IncrementCount());
          HapticFeedback.mediumImpact();

          setState(() {
            _updateRotation(0.2); // Animate forward slightly on tap
          });

          Future.delayed(const Duration(milliseconds: 300), () {
            _lockBeadPassDetection = false;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: RepaintBoundary(
            child: CustomPaint(
              painter: TasbihPainter(
                angle: _rotationAngle,
                beadCount:
                    33, // Fixed to 33 beads visually for aesthetic consistency
                material: state.material,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.refresh_rounded, 'إعادة', () {
            _tasbihBloc.add(ResetTasbih());
            setState(() {
              _rotationAngle = 0.0;
              _lastBeadIndex = 0;
            });
          }),
          _buildActionButton(
            Icons.tune_rounded,
            'تعديل',
            () => _showSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bContext) => BlocProvider.value(
        value: _tasbihBloc,
        child: const TasbihSettingsSheet(),
      ),
    );
  }
}

class TasbihPainter extends CustomPainter {
  final double angle;
  final int beadCount;
  final String material;

  TasbihPainter({
    required this.angle,
    required this.beadCount,
    required this.material,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // For now let's use fixed gold for string as it fits both themes elegantly.
    // For now let's use fixed gold for string as it fits both themes elegantly.
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final perspectiveRadiusY = radius * 0.75;

    // Draw string
    final stringPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: perspectiveRadiusY * 2,
      ),
      stringPaint,
    );

    List<Map<String, dynamic>> beads = [];
    for (int i = 0; i < beadCount; i++) {
      final beadAngle = (i * 2 * math.pi / beadCount) + angle;
      final z = math.sin(beadAngle);
      beads.add({'z': z, 'angle': beadAngle});
    }

    // Sort to draw back beads first
    beads.sort((a, b) => a['z'].compareTo(b['z']));

    for (var beadData in beads) {
      final beadAngle = beadData['angle'];
      final z = beadData['z'];

      final x = center.dx + radius * math.cos(beadAngle);
      final y = center.dy + perspectiveRadiusY * math.sin(beadAngle);

      final scale = 1.0 + (z * 0.4); // Subtle scale variation
      final beadSize = 17.0 * scale; // Elegant sizing
      final brightness = (z + 1.2) / 2.2; // Adjusted for global lighting

      // Color selection based on material
      Color baseColor;
      Color highlightColor = Colors.white;
      double shininess = 1.0;

      switch (material) {
        case 'gold':
          baseColor = const Color(0xFFC5A028); // Deeper gold
          highlightColor = const Color(0xFFFFFDE7);
          shininess = 1.8;
          break;
        case 'wood':
          baseColor = const Color(0xFF4E342E); // Richer wood
          highlightColor = const Color(0xFF8D6E63);
          shininess = 0.4;
          break;
        case 'marble':
          baseColor = const Color(0xFFFAFAFA);
          highlightColor = Colors.white;
          shininess = 0.7;
          break;
        case 'emerald':
        default:
          baseColor = const Color(0xFF00695C); // Premium Emerald
          highlightColor = const Color(0xFFB2DFDB);
          shininess = 1.4;
      }

      // Draw shadow on the background (soften it)
      if (z > -0.7) {
        canvas.drawCircle(
          Offset(x + 4, y + 6),
          beadSize,
          Paint()
            ..color = Colors.black.withOpacity(0.08 * brightness)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }

      // Main Bead Gradient (Multi-layer for depth)
      final paint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: [
            Color.lerp(highlightColor, baseColor, 0.05)!,
            baseColor,
            Color.lerp(baseColor, Colors.black, 0.5)!,
            const Color(0xFF000000),
          ],
          stops: const [0.0, 0.35, 0.8, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: beadSize));

      canvas.drawCircle(Offset(x, y), beadSize, paint);

      // Material-specific Specular Reflection
      if (z > -0.3) {
        final specularOpacity = 0.5 * brightness * shininess;
        final specularPaint = Paint()
          ..color = highlightColor.withOpacity(specularOpacity.clamp(0.0, 0.8))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

        canvas.drawCircle(
          Offset(x - beadSize * 0.38, y - beadSize * 0.38),
          beadSize * 0.2,
          specularPaint,
        );

        // Ambient environment reflection (subtle bottom highlight)
        final rimPaint = Paint()
          ..color = highlightColor.withOpacity(0.12 * brightness)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

        canvas.drawArc(
          Rect.fromCircle(center: Offset(x, y), radius: beadSize - 2),
          math.pi * 0.2,
          math.pi * 0.6,
          false,
          rimPaint,
        );
      }

      // Focal point indicator at bottom
      final normAngle = (beadAngle % (2 * math.pi));
      final distToFocal = (normAngle - math.pi / 2).abs();
      if (distToFocal < (math.pi / beadCount)) {
        final focalPaint = Paint()
          ..color = const Color(
            0xFFD4AF37,
          ).withOpacity(0.4 * (1.0 - distToFocal / (math.pi / beadCount)))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
        canvas.drawCircle(Offset(x, y), beadSize + 3, focalPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TasbihPainter oldDelegate) =>
      oldDelegate.angle != angle ||
      oldDelegate.beadCount != beadCount ||
      oldDelegate.material != material;
}
