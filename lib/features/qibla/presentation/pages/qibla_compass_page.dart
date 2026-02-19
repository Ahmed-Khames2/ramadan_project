import 'dart:math' show pi, atan2, sqrt, cos, sin;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_compass/flutter_compass.dart';

import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:ramadan_project/features/qibla/presentation/widgets/qibla_arrow_painter.dart';
import 'package:ramadan_project/features/qibla/presentation/widgets/modern_compass_painter.dart';
import 'package:ramadan_project/features/qibla/presentation/widgets/qibla_info_card.dart';
import 'package:ramadan_project/features/qibla/presentation/widgets/qibla_error_widget.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';

class QiblaCompassPage extends StatefulWidget {
  const QiblaCompassPage({super.key});

  @override
  State<QiblaCompassPage> createState() => _QiblaCompassPageState();
}

class _QiblaCompassPageState extends State<QiblaCompassPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  double? _qiblahDirection;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _initializeQibla();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _errorMessage != null) {
      // Retry initialization when app returns from background if there was an error
      _initializeQibla();
    }
  }

  Future<void> _initializeQibla() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'يرجى السماح بالوصول إلى الموقع لمشاهدة القبلة';
          _isLoading = false;
        });
        return;
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
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'اتجاه القبلة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
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
              Theme.of(context).colorScheme.primary.withOpacity(0.08),
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.secondary.withOpacity(0.06),
            ],
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري تحديد الموقع...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
            ? QiblaErrorWidget(
                errorMessage: _errorMessage,
                onRetry: _initializeQibla,
              )
            : _buildCompassView(),
      ),
    );
  }

  Widget _buildCompassView() {
    final distance = _calculateDistance();

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError || (!snapshot.hasData && kIsWeb)) {
          // Fallback for Web or Desktop where compass sensors are missing
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _buildWebManualNotice(),
                  const SizedBox(height: 20),
                  _buildModernCompass(0, _qiblahDirection ?? 0),
                  const SizedBox(height: 32),
                  _buildInfoCards(distance),
                  const SizedBox(height: 16),
                  _buildInstructionCard(),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
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
                _buildInfoCards(distance),

                const SizedBox(height: 16),

                const SizedBox(height: 24),
                const OrnamentalDivider(),
                const SizedBox(height: 24),

                // Instruction
                _buildInstructionCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernCompass(double heading, double qiblahOffset) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(isDark ? 0.8 : 0.5),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
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
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.4),
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone_android_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${heading.toStringAsFixed(1)}°',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(double distance) {
    return Row(
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
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              kIsWeb
                  ? 'اتجاه القبلة من جهة الشمال هو السهم الذهبي'
                  : 'وجه الجهاز نحو السهم الذهبي',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebManualNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'حساس البوصلة غير متوفر على هذا الجهاز. يظهر السهم اتجاه القبلة بالنسبة للشمال.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
