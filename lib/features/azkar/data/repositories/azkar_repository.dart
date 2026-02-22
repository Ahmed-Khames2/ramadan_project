import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/azkar_model.dart';

class AzkarRepository {
  Future<List<AzkarItem>> getAllAzkar() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/azkar.json',
      );
      final dynamic decoded = json.decode(response);

      if (decoded is List) {
        return decoded
            .map((json) => AzkarItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
