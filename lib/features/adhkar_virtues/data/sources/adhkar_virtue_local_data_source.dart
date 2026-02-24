import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/adhkar_virtue_model.dart';

abstract class AdhkarVirtueLocalDataSource {
  Future<List<AdhkarVirtueModel>> getAdhkarVirtues();
}

class AdhkarVirtueLocalDataSourceImpl implements AdhkarVirtueLocalDataSource {
  @override
  Future<List<AdhkarVirtueModel>> getAdhkarVirtues() async {
    final String response = await rootBundle.loadString(
      'assets/json/hadiss/fadel.json',
    );
    return compute(_parseAdhkarVirtues, response);
  }
}

List<AdhkarVirtueModel> _parseAdhkarVirtues(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => AdhkarVirtueModel.fromJson(json)).toList();
}
