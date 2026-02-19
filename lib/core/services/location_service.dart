import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';

class LocationService {
  final Dio _dio = Dio();

  Future<Position?> determinePosition() async {
    print('LocationService: Determine position started');
    LocationPermission permission;

    // 1. Check Permission First
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // 2. Check Service Status
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('LocationService Error: $e');
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
