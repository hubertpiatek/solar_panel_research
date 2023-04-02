import 'package:intl/intl.dart';
import 'package:solar_panel_research/model/solar_data_single_model.dart';

class SummaryModel {
  static const solarPanelSavesPerMinute = 6;
  double generatedPower;
  double averageVoltage;
  double averageCurrent;
  double averageTemperature;
  List<SolarDataModel> solarDataModel;

  SummaryModel(
      {required this.generatedPower,
      required this.averageVoltage,
      required this.averageCurrent,
      required this.averageTemperature,
      required this.solarDataModel});

  Future<SummaryModel> init(Map<String, dynamic> json) async {
    List<SolarDataModel> solarDataModel = [];
    double averageVoltage = 0.0;
    double averageCurrent = 0.0;
    double averageTemperature = 0.0;
    double generatedPower = 0.0;
    await Future.forEach(json.values, (items) async {
      Map<String, dynamic> solarDataList = items;
      try {
        await Future.forEach(solarDataList.values,
            (solarDataSingleModel) async {
          try {
            DateTime solarDate = DateFormat("dd-MM-yyyy HH:mm:ss")
                .parse(solarDataSingleModel['dateAndTime'] ?? "");
            //Tylko Dane Pomiędzy 7 i 21
            if (solarDate.hour >= 7 && solarDate.hour <= 20) {
              solarDataModel.add(SolarDataModel.fromJson(solarDataSingleModel));
            }
          } catch (_) {}
        });
      } catch (error) {
        rethrow;
      }
    });
    solarDataModel.sort((a, b) => a.solarDate.compareTo(b.solarDate));
    await Future.forEach(solarDataModel, (singleSolarDataMode) {
      averageVoltage += singleSolarDataMode.voltage;
      averageCurrent += singleSolarDataMode.current;
      averageTemperature += singleSolarDataMode.temperature;
      generatedPower +=
          (singleSolarDataMode.voltage * singleSolarDataMode.current);
    });
    averageVoltage = double.parse(
        (averageVoltage / solarDataModel.length).toStringAsFixed(2));
    averageCurrent = double.parse(
        (averageCurrent / solarDataModel.length).toStringAsFixed(2));
    averageTemperature = double.parse(
        (averageTemperature / solarDataModel.length).toStringAsFixed(2));
    //6 Liczba odczytów panelu na godzinę
    //1000 - przeliczenie Wh na kWh
    generatedPower = double.parse(
        (generatedPower / solarPanelSavesPerMinute / 1000).toStringAsFixed(3));
    return SummaryModel(
      generatedPower: generatedPower,
      averageVoltage: averageVoltage,
      averageCurrent: averageCurrent,
      averageTemperature: averageTemperature,
      solarDataModel: solarDataModel,
    );
  }
}
