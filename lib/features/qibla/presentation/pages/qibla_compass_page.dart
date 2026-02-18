import 'dart:math' show pi, atan2, sqrt, cos, sin;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:ramadan_project/features/qibla/presentation/widgets/qibla_arrow_painter.dart';
import 'package:ramadan_project/features/qibla/presentation/widgets/modern_compass_painter.dart';
import 'package:ramadan_project/features/qibla/presentation/widgets/qibla_info_card.dart';
import 'package:ramadan_project/features/qibla/presentation/widgets/qibla_error_widget.dart';

class QiblaCompassPage extends StatefulWidget {
  const QiblaCompassPage({super.key});

  @override
  State<QiblaCompassPage> createState() => _QiblaCompassPageState();
}

class _QiblaCompassPageState extends State<QiblaCompassPage>
    with SingleTickerProviderStateMixin {
  double? _qiblahDirection;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _initializeQibla();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeQibla() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() {
            _errorMessage = 'يرجى السماح بالوصول إلى الموقع';
            _isLoading = false;
          });
          return;
        }
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'يرجى تفعيل خدمة الموقع';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final coordinates = Coordinates(position.latitude, position.longitude);
      final qibla = Qibla(coordinates);
      final qiblahDirection = qibla.direction;

      setState(() {
        _currentPosition = position;
        _qiblahDirection = qiblahDirection;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  double _calculateDistance() {
    if (_currentPosition == null) return 0;
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;
    const earthRadius = 6371;
    final dLat = _degreesToRadians(kaabaLat - _currentPosition!.latitude);
    final dLng = _degreesToRadians(kaabaLng - _currentPosition!.longitude);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(_currentPosition!.latitude)) *
            cos(_degreesToRadians(kaabaLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.primaryEmerald,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'اتجاه القبلة',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryEmerald,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryEmerald.withOpacity(0.08),
              const Color(0xFFF5F9F7),
              AppTheme.accentGold.withOpacity(0.06),
            ],
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryEmerald,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري تحديد الموقع...',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
            ? QiblaErrorWidget(errorMessage: _errorMessage)
            : _buildCompassView(),
      ),
    );
  }

  Widget _buildCompassView() {
    final distance = _calculateDistance();

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطأ في قراءة البوصلة',
              style: GoogleFonts.cairo(color: AppTheme.textGrey),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryEmerald),
          );
        }

        final compassHeading = snapshot.data!.heading ?? 0;
        final qiblahOffset = (_qiblahDirection ?? 0) - compassHeading;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Main Compass
                _buildModernCompass(compassHeading, qiblahOffset),

                const SizedBox(height: 32),

                // Info Cards
                Row(
                  children: [
                    Expanded(
                      child: QiblaInfoCard(
                        icon: Icons.explore_rounded,
                        label: 'الاتجاه',
                        value: '${(_qiblahDirection ?? 0).toStringAsFixed(1)}°',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QiblaInfoCard(
                        icon: Icons.location_on_rounded,
                        label: 'المسافة',
                        value: '${distance.toStringAsFixed(0)} كم',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Instruction
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryEmerald.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.accentGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'وجه الجهاز نحو السهم الذهبي',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernCompass(double heading, double qiblahOffset) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryEmerald.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compass Circle
          SizedBox(
            height: 340,
            width: 340,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating compass ring
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: -heading * (pi / 180),
                      child: CustomPaint(
                        size: const Size(340, 340),
                        painter: ModernCompassPainter(
                          pulseValue: _pulseController.value,
                        ),
                      ),
                    );
                  },
                ),

                // Qibla arrow
                Transform.rotate(
                  angle: qiblahOffset * (pi / 180),
                  child: CustomPaint(
                    size: const Size(120, 120),
                    painter: QiblaArrowPainter(),
                  ),
                ),

                // Center Kaaba icon
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryEmerald,
                        AppTheme.primaryEmerald.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryEmerald.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Degree indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryEmerald.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: AppTheme.primaryEmerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${heading.toStringAsFixed(1)}°',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryEmerald,
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
