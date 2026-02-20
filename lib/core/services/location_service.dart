import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';

class LocationService {
  final Dio _dio = Dio();

  Future<Position?> determinePosition() async {
    print('LocationService: Determine position started');

    // 1. Check Service Status
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('LocationService: Service not enabled');
      return null;
    }

    // 2. Check Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('LocationService: Permission denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('LocationService: Permission denied forever');
      return null;
    }

    try {
      // 3. Try Last Known Position first for speed
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        print('LocationService: Using last known position');
        // Still try to get fresh position in background or return this for now
        // For simplicity and matching user request for "doesn't get my location",
        // we'll return lastKnown but also try fresh if it's very old?
        // Let's just try fresh first with a short timeout, then fallback.
      }

      // 4. Check granted accuracy level
      final accuracyStatus = await Geolocator.getLocationAccuracy();

      // If user chose "Approximate", we MUST use medium or low accuracy
      // High accuracy requests might fail on some devices with only coarse permission
      final desiredAccuracy = (accuracyStatus == LocationAccuracyStatus.reduced)
          ? LocationAccuracy.medium
          : LocationAccuracy.high;

      print(
        'LocationService: Requesting position with accuracy: $desiredAccuracy',
      );

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: desiredAccuracy,
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 16),
        onTimeout: () async {
          print('LocationService: Current position timeout');
          final pos = await Geolocator.getLastKnownPosition();
          if (pos != null) return pos;
          throw TimeoutException(
            'Location request timed out and no last known position available',
          );
        },
      );
    } catch (e) {
      print('LocationService Error: $e');
      // Final fallback to last known
      return await Geolocator.getLastKnownPosition();
    }
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openAppSettings();
  }

  Future<String?> getCityFromCoordinates(double lat, double lng) async {
    if (kIsWeb) {
      return await _getCityFromWeb(lat, lng);
    }
    try {
      await setLocaleIdentifier('ar');
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ??
            placemarks.first.subAdministrativeArea;
      }
    } catch (e) {
      print('Geocoding Error: $e');
      return await _getCityFromWeb(
        lat,
        lng,
      ); // Fallback to web geocoding if mobile fails
    }
    return null;
  }

  Future<String?> _getCityFromWeb(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': lat,
          'lon': lng,
          'accept-language': 'ar',
        },
        options: Options(
          headers: {
            'User-Agent':
                'RamadanProject/1.0', // Nominatim requires a User-Agent
          },
        ),
      );

      if (response.statusCode == 200) {
        final address = response.data['address'];
        if (address != null) {
          return address['city'] ??
              address['town'] ??
              address['village'] ??
              address['suburb'] ??
              address['state'];
        }
      }
    } catch (e) {
      print('Web Geocoding Error: $e');
    }
    return null;
  }
}
