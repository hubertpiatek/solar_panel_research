import 'solar_data_single_model.dart';

class LastSolarDataModel {
  DateTime solarDate;
  List<SolarDataModel> singleSolarData;

  LastSolarDataModel({
    required this.solarDate,
    required this.singleSolarData,
  });

  factory LastSolarDataModel.fromJson(Map<String, dynamic> json) {
    return LastSolarDataModel(
      solarDate: json['solarDate'],
      singleSolarData: json['singleSolarData'],
    );
  }
}
