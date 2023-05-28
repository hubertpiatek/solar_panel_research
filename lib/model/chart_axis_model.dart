import 'chart_model.dart';

class ChartAxisModel {
  late double solarChartMinYValue;
  late double solarChartMaxYValue;
  late double solarChartMinXValue;
  late double solarChartMaxXValue;
  late String xAxisText;
  late String actualSelectedFilter;
  late bool isDateSingleDay;
  late bool isPeriod;
  late DateTime selectedDate;

  // ChartAxisModel({
  //   required this.solarChartMinYValue,
  //   required this.solarChartMaxYValue,
  //   required this.solarChartMinXValue,
  //   required this.solarChartMaxXValue,
  //   required this.xAxisText,
  // });

  ChartAxisModel() {
    solarChartMinYValue = 0.0;
    solarChartMaxYValue = 0.0;
    solarChartMinXValue = 0.0;
    solarChartMaxXValue = 0.0;
    xAxisText = "";
    actualSelectedFilter = ChartModel.chartFilterInfo[ChartFilterTypes.power]!;
    isDateSingleDay = false;
    isPeriod = false;
    selectedDate = DateTime.now();
  }
}
