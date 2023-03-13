import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../common/http_exception.dart';
import '../model/summary_model.dart';

class SolarPanelResearchService {
  final solarDb = FirebaseDatabase.instance.ref();
  Future<SummaryModel> getSummaryData() async {
    final DataSnapshot summarySolarData =
        await solarDb.child("solarDataFromSun").get();
    if (summarySolarData.exists) {
      String stringSummaryData = jsonEncode(summarySolarData.value);
      Map<String, dynamic> summarySolarDataMap = jsonDecode(stringSummaryData);
      return SummaryModel.fromJson(summarySolarDataMap);
    } else {
      return SummaryModel(
          generatedPower: 0.0,
          averageVoltage: 0.0,
          averageCurrent: 0.0,
          averageTemperature: 0.0,
          solarDataModel: []);
    }
  }

  Future<void> getLastSolarData() async {
    try {
      final DataSnapshot solarData =
          await solarDb.child("solarDataFromSun/01-10-2022").get();
      if (solarData.exists) {
        if (kDebugMode) {
          print(solarData.value.toString());
        }
        String s = jsonEncode(solarData.value);
        var user = jsonDecode(s);
        var x = 5;
      } else {
        if (kDebugMode) {
          print('No data available.');
        }
      }
    } catch (error) {
      rethrow;
    }
    // await Future.delayed(const Duration(milliseconds: 200));
  }
}
