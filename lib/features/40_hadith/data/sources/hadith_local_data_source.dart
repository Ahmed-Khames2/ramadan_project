import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/hadith_model.dart';

abstract class HadithLocalDataSource {
  Future<List<HadithModel>> getHadiths();
}

class HadithLocalDataSourceImpl implements HadithLocalDataSource {
  @override
  Future<List<HadithModel>> getHadiths() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/hadiss/40-hadith-nawawi.json',
      );
      final data = await compute(json.decode, response) as List;
      return data
          .asMap()
          .entries
          .map((entry) => HadithModel.fromJson(entry.value, entry.key))
          .toList();
    } catch (e) {
      throw Exception('Failed to load hadiths from assets: $e');
    }
  }
}
