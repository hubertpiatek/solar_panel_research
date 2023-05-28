import 'package:fl_chart/fl_chart.dart';
import 'package:solar_panel_research/model/solar_data_single_model.dart';

import 'chart_axis_model.dart';

enum ChartFilterTypes {
  power,
  voltage,
  current,
  temperature,
  humidity,
  lightIntensity,
  angle
}

class ChartModel {
  static const Map<ChartFilterTypes, String> chartFilterInfo = {
    ChartFilterTypes.power: "Moc [ W ]",
    ChartFilterTypes.voltage: "Napięcie [ V ]",
    ChartFilterTypes.current: "Natężenie [ A ]",
    ChartFilterTypes.temperature: "Temperatura [ °C ]",
    ChartFilterTypes.humidity: "Wilgotność [ % ]",
    ChartFilterTypes.lightIntensity: "Intensywność [ Lux ]",
    ChartFilterTypes.angle: "Kąt panelu [ ° ]",
  };

  List<SolarDataModel> chartData;
  List<FlSpot> chartFlSpotList;
  static ChartAxisModel chartAxisModelLast = ChartAxisModel();
  static ChartAxisModel chartAxisModelHistoric = ChartAxisModel();

  ChartModel({required this.chartData, required this.chartFlSpotList});
}
