import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import '../model/summary_model.dart';

class SolarPanelResearchService {
  final solarDb = FirebaseDatabase.instance.ref();
  Future<SummaryModel> getSummaryData() async {
    try {
      final DataSnapshot summarySolarData = await solarDb
          .child("solarDataFromSun")
          .get()
          .timeout(const Duration(seconds: 15));
      if (summarySolarData.exists) {
        String stringSummaryData = jsonEncode(summarySolarData.value);
        Map<String, dynamic> summarySolarDataMap =
            jsonDecode(stringSummaryData);
        return SummaryModel.fromJson(summarySolarDataMap);
      } else {
        return SummaryModel(
            generatedPower: 0.0,
            averageVoltage: 0.0,
            averageCurrent: 0.0,
            averageTemperature: 0.0,
            solarDataModel: []);
      }
    } on TimeoutException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
