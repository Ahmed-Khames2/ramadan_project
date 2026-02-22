import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';

class LocationService {
  final Dio _dio = Dio();

  Future<Position?> determinePosition() async {
    // 1. Check Service Status
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // 2. Check Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      // 3. Try Last Known Position first for speed (not supported on Web)
      if (!kIsWeb) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          // Return last known, still proceed to get fresh below
        }
      }

      // 4. On Web, skip accuracy check as it's not supported
      LocationAccuracy desiredAccuracy = LocationAccuracy.high;
      if (!kIsWeb) {
        final accuracyStatus = await Geolocator.getLocationAccuracy();
        desiredAccuracy = (accuracyStatus == LocationAccuracyStatus.reduced)
            ? LocationAccuracy.medium
            : LocationAccuracy.high;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: desiredAccuracy,
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 16),
        onTimeout: () async {
          // getLastKnownPosition is not supported on Web
          if (!kIsWeb) {
            final pos = await Geolocator.getLastKnownPosition();
            if (pos != null) return pos;
          }
          throw TimeoutException('Location request timed out');
        },
      );
    } catch (e) {
      // Final fallback to last known (mobile only)
      if (!kIsWeb) {
        return await Geolocator.getLastKnownPosition();
      }
      return null;
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
      return await _getCityFromWeb(lat, lng);
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
        options: Options(headers: {'User-Agent': 'RamadanProject/1.0'}),
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
    } catch (e) {}
    return null;
  }
}
