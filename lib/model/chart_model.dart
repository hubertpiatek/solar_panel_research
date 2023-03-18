import 'package:fl_chart/fl_chart.dart';
import 'package:solar_panel_research/model/solar_data_single_model.dart';

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

  String actualSelectedFilter;
  List<SolarDataModel> chartData;
  List<FlSpot> chartFlSpotList;
  double solarChartMinYValue;
  double solarChartMaxYValue;
  double solarChartMinXValue;
  double solarChartMaxXValue;
  String xAxisText;
  DateTime selectedDate;
  bool isDateSingleDay;
  bool isPeriod;

  ChartModel({
    required this.actualSelectedFilter,
    required this.chartData,
    required this.chartFlSpotList,
    required this.solarChartMinYValue,
    required this.solarChartMaxYValue,
    required this.solarChartMinXValue,
    required this.solarChartMaxXValue,
    required this.xAxisText,
    required this.selectedDate,
    required this.isDateSingleDay,
    required this.isPeriod,
  });
}
