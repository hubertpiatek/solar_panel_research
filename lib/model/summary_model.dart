import 'package:intl/intl.dart';
import 'package:solar_panel_research/model/solar_data_single_model.dart';

class SummaryModel {
  static const solarPanelSavesPerMinute = 84;
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

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    List<SolarDataModel> solarDataModel = [];
    double averageVoltage = 0.0;
    double averageCurrent = 0.0;
    double averageTemperature = 0.0;
    double generatedPower = 0.0;
    json.forEach((day, items) {
      Map<String, dynamic> solarDataList = items;
      try {
        solarDataList.forEach((hour, solarDataSingleModel) {
          DateTime formattedDate =
              DateFormat("dd-MM-yyyy hh:mm:ss").parse("$day 00:00:00");
          DateTime formattedDateHour =
              DateFormat("dd-MM-yyyy hh:mm:ss").parse("01-01-1990 $hour");
          //Tylko Dane Pomiędzy 6 i 21
          if (formattedDateHour.hour >= 6 && formattedDateHour.hour <= 20) {
            formattedDate = formattedDate.add(Duration(
                hours: formattedDateHour.hour,
                minutes: formattedDateHour.minute,
                seconds: formattedDateHour.second));
            solarDataModel.add(
                SolarDataModel.fromJson(solarDataSingleModel, formattedDate));
          }
        });
      } catch (error) {
        print(error);
      }
    });
    solarDataModel.sort((a, b) => a.solarDate.compareTo(b.solarDate));

    for (var singleSolarDataMode in solarDataModel) {
      averageVoltage += singleSolarDataMode.voltage;
      averageCurrent += singleSolarDataMode.current;
      averageTemperature += singleSolarDataMode.temperature;
      generatedPower +=
          (singleSolarDataMode.voltage * singleSolarDataMode.current);
    }
    averageVoltage = double.parse(
        (averageVoltage / solarDataModel.length).toStringAsFixed(2));
    averageCurrent = double.parse(
        (averageCurrent / solarDataModel.length).toStringAsFixed(2));
    averageTemperature = double.parse(
        (averageTemperature / solarDataModel.length).toStringAsFixed(2));
    //84 Liczba odczytów panelu na godzinę
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
