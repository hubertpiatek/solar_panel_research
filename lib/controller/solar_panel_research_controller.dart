import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solar_panel_research/service/solar_panel_research_service.dart';
import 'package:weather/weather.dart';
import '../common/error_alert_dialog.dart';
import '../common/waiting_dialog.dart';
import '../model/chart_model.dart';
import '../model/stats_model.dart';
import '../model/summary_model.dart';
import 'package:geolocator/geolocator.dart';

enum HistoricFilterTypes { lastWeek, lastMonth, lastThreeMonths }

class SolarPanelResearchController extends ChangeNotifier {
  static const Map<HistoricFilterTypes, String> historicFilters = {
    HistoricFilterTypes.lastWeek: "Ostatni tydzień",
    HistoricFilterTypes.lastMonth: "Ostatni miesiąc",
    HistoricFilterTypes.lastThreeMonths: "Ostatnie 3 miesiące",
  };
  late ChartModel _chartModelLast;
  late ChartModel _chartModelHistoric;
  late String _actualSelectedHistoricPeriodFilter;
  late SolarPanelResearchService _solarPanelResearchService;
  late bool _isSummaryDataLoading;
  late bool _isLastDataLoading;
  late bool _isHistoricChartView;
  late SummaryModel _summaryModel;
  late bool _isAfterInit;
  late WeatherFactory _weatherFactory;
  late Position _userPosition;
  late StatsModel _solarStatsModel;
  Weather? _weather;

  SolarPanelResearchController() {
    _solarPanelResearchService = SolarPanelResearchService();
    _isSummaryDataLoading = false;
    _isLastDataLoading = false;
    _isHistoricChartView = false;
    _chartModelLast = ChartModel(
        actualSelectedFilter:
            ChartModel.chartFilterInfo[ChartFilterTypes.power]!,
        chartData: [],
        chartFlSpotList: [],
        solarChartMinYValue: 0.0,
        solarChartMaxYValue: 120.0,
        solarChartMinXValue: 6.0,
        solarChartMaxXValue: 22.0,
        xAxisText: "Czas [ h ]",
        selectedDate: DateTime(2022, 10, 1),
        isDateSingleDay: true,
        isPeriod: false);
    _chartModelHistoric = ChartModel(
        actualSelectedFilter:
            ChartModel.chartFilterInfo[ChartFilterTypes.power]!,
        chartData: [],
        chartFlSpotList: [],
        solarChartMinYValue: 0.0,
        solarChartMaxYValue: 120.0,
        solarChartMinXValue: 6.0,
        solarChartMaxXValue: 22.0,
        xAxisText: historicFilters[HistoricFilterTypes.lastWeek]!,
        selectedDate: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .subtract(const Duration(days: 7)),
        isDateSingleDay: false,
        isPeriod: false);
    _summaryModel = SummaryModel(
      averageCurrent: 0.0,
      averageTemperature: 0.0,
      averageVoltage: 0.0,
      generatedPower: 0.0,
      solarDataModel: [],
    );
    _solarStatsModel = StatsModel(
        generatedPower: 0.0,
        averageVoltage: 0.0,
        averageCurrent: 0.0,
        averageTemperature: 0.0,
        averageHumidity: 0,
        averageLightIntensity: 0.0,
        lastdirection: "");
    _actualSelectedHistoricPeriodFilter =
        historicFilters[HistoricFilterTypes.lastWeek]!;
    _isAfterInit = false;
    _weatherFactory = WeatherFactory("a3de4ad59cc610af18180b1c4fb5f58d",
        language: Language.POLISH);
    _userPosition = const Position(
        accuracy: 0,
        altitude: 0,
        heading: 0,
        latitude: 0,
        longitude: 0,
        speed: 0,
        speedAccuracy: 0,
        timestamp: null);
    _weather = null;
  }

  ChartModel get chartModelLast {
    return _chartModelLast;
  }

  set setChartModelLast(ChartModel chartModelLast) {
    _chartModelLast = chartModelLast;
  }

  StatsModel get solarStatsModel {
    return _solarStatsModel;
  }

  set setSolarStatsModel(StatsModel solarStatsModel) {
    _solarStatsModel = solarStatsModel;
  }

  bool get isHistoricChartView {
    return _isHistoricChartView;
  }

  set setIsHistoricChartView(bool isHistoricChartView) {
    _isHistoricChartView = isHistoricChartView;
  }

  ChartModel get chartModelHistoric {
    return _chartModelHistoric;
  }

  set setChartModelHistoric(ChartModel chartModelHistoric) {
    _chartModelHistoric = chartModelHistoric;
  }

  Weather? get weather {
    return _weather;
  }

  set setWeather(Weather? weather) {
    _weather = weather;
  }

  Position get userPosition {
    return _userPosition;
  }

  set setUserPosition(Position userPosition) {
    _userPosition = userPosition;
  }

  WeatherFactory get weatherFactory {
    return _weatherFactory;
  }

  set setWeatherFactory(WeatherFactory weatherFactory) {
    _weatherFactory = weatherFactory;
  }

  String get actualSelectedHistoricPeriodFilter {
    return _actualSelectedHistoricPeriodFilter;
  }

  set setActualSelectedHistoricPeriodFilter(
      String actualSelectedHistoricPeriodFilter) {
    _actualSelectedHistoricPeriodFilter = actualSelectedHistoricPeriodFilter;
  }

  SummaryModel get summaryModel {
    return _summaryModel;
  }

  set setSummaryModel(SummaryModel summaryModel) {
    _summaryModel = summaryModel;
  }

  bool get isSummaryDataLoading {
    return _isSummaryDataLoading;
  }

  set setIsSummaryDataLoading(bool isSummaryDataLoading) {
    _isSummaryDataLoading = isSummaryDataLoading;
    notifyListeners();
  }

  bool get isAfterInit {
    return _isAfterInit;
  }

  set setIsAfterInit(bool isAfterInit) {
    _isAfterInit = isAfterInit;
  }

  bool get isLastDataLoading {
    return _isLastDataLoading;
  }

  set setIsLastDataLoading(bool isLastDataLoading) {
    _isLastDataLoading = isLastDataLoading;
    notifyListeners();
  }

  SolarPanelResearchService get solarPanelResearchService {
    return _solarPanelResearchService;
  }

  set setSolarPanelResearchService(
      SolarPanelResearchService solarPanelResearchService) {
    _solarPanelResearchService = solarPanelResearchService;
  }

  Future<void> getSummaryData() async {
    setIsSummaryDataLoading = true;
    _summaryModel = await _solarPanelResearchService.getSummaryData();
    //Pobierz ostatnie dane i pokaż na wykresie
    _chartModelLast.chartData = _summaryModel.solarDataModel
        .where((solarSingleData) =>
            solarSingleData.solarDate.year ==
                _summaryModel.solarDataModel.last.solarDate.year &&
            solarSingleData.solarDate.month ==
                _summaryModel.solarDataModel.last.solarDate.month &&
            solarSingleData.solarDate.day ==
                _summaryModel.solarDataModel.last.solarDate.day)
        .toList();
    await setSolarChartFilter(_chartModelLast.actualSelectedFilter,
        isHistoric: false);

    //Pobierz dane historyczne i pokaż na wykresie
    if (_chartModelHistoric.isDateSingleDay) {
      _chartModelHistoric.chartData = _summaryModel.solarDataModel
          .where((solarSingleData) =>
              solarSingleData.solarDate.year ==
                  _chartModelHistoric.selectedDate.year &&
              solarSingleData.solarDate.month ==
                  _chartModelHistoric.selectedDate.month &&
              solarSingleData.solarDate.day ==
                  _chartModelHistoric.selectedDate.day)
          .toList();
    } else {
      _chartModelHistoric.chartData = _summaryModel.solarDataModel
          .where((solarSingleData) => solarSingleData.solarDate
              .isAfter(_chartModelHistoric.selectedDate))
          .toList();
    }
    await setSolarChartFilter(_chartModelHistoric.actualSelectedFilter,
        isHistoric: true);

    setIsSummaryDataLoading = false;
  }

  Future<void> getSummaryDataFromPanel(
      BuildContext context, bool mounted) async {
    try {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return const WaitingDialog(
              dialogContent:
                  "Trwa ładowanie i przetwarzanie danych z panelu fotowoltaicznego. Proszę czekać....",
            );
          });
      await getSummaryData();
      await getUserPositionForWeather();
      await getWeather();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      Navigator.of(context).pop();
      await showDialog(
        context: context,
        builder: (context) {
          return ErrorAlertDialog(errorContent: error.toString());
        },
      );
      setIsSummaryDataLoading = false;
    }
  }

  Future<void> setSolarChartFilter(String value,
      {required bool isHistoric}) async {
    ChartModel chartModel = isHistoric ? _chartModelHistoric : _chartModelLast;
    chartModel.actualSelectedFilter = value;
    List<FlSpot> chartFlSpotList = [];
    chartModel.chartFlSpotList = [];
    chartModel.solarChartMinXValue = 0;
    chartModel.solarChartMaxXValue = 0;
    if (chartModel.chartData.isNotEmpty) {
      ChartFilterTypes chartFilter = ChartModel.chartFilterInfo.keys
          .firstWhere((key) => ChartModel.chartFilterInfo[key] == value);
      chartModel.solarChartMinXValue =
          chartModel.chartData.first.solarDate.millisecondsSinceEpoch / 100000;
      chartModel.solarChartMaxXValue =
          chartModel.chartData.last.solarDate.millisecondsSinceEpoch / 100000;
      switch (chartFilter) {
        case ChartFilterTypes.power:
          chartModel.solarChartMinYValue = 0;
          chartModel.solarChartMaxYValue = 110;
          for (var singleSolarData in chartModel.chartData) {
            chartFlSpotList.add(FlSpot(
                singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                singleSolarData.power));
          }
          break;
        case ChartFilterTypes.voltage:
          chartModel.solarChartMinYValue = 0;
          chartModel.solarChartMaxYValue = 22;
          for (var singleSolarData in chartModel.chartData) {
            chartFlSpotList.add(FlSpot(
                singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                singleSolarData.voltage));
          }
          break;
        case ChartFilterTypes.current:
          chartModel.solarChartMinYValue = 0;
          chartModel.solarChartMaxYValue = 5.5;
          for (var singleSolarData in chartModel.chartData) {
            chartFlSpotList.add(FlSpot(
                singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                singleSolarData.current));
          }
          break;
        case ChartFilterTypes.temperature:
          chartModel.solarChartMinYValue = 0;
          chartModel.solarChartMaxYValue = 35;
          for (var singleSolarData in chartModel.chartData) {
            chartFlSpotList.add(FlSpot(
                singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                singleSolarData.temperature));
          }
          break;
        case ChartFilterTypes.humidity:
          chartModel.solarChartMinYValue = 0;
          chartModel.solarChartMaxYValue = 100;
          for (var singleSolarData in chartModel.chartData) {
            chartFlSpotList.add(FlSpot(
                singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                singleSolarData.humidity.toDouble()));
          }
          break;
        case ChartFilterTypes.lightIntensity:
          chartModel.solarChartMinYValue = 0;
          chartModel.solarChartMaxYValue = 65000;
          for (var singleSolarData in chartModel.chartData) {
            chartFlSpotList.add(FlSpot(
                singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                singleSolarData.lightIntensity));
          }
          break;
        case ChartFilterTypes.angle:
          chartModel.solarChartMinYValue = 0;
          chartModel.solarChartMaxYValue = 50;
          for (var singleSolarData in chartModel.chartData) {
            chartFlSpotList.add(FlSpot(
                singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                singleSolarData.solarAngle.toDouble()));
          }
          break;
        default:
          chartModel.solarChartMinYValue = 0;
          chartModel.solarChartMaxYValue = 110;
          for (var singleSolarData in chartModel.chartData) {
            chartFlSpotList.add(FlSpot(
                singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                singleSolarData.power));
          }
          break;
      }
    }
    if (isHistoric) {
      await getHistoricStats();
    }
    chartModel.chartFlSpotList = chartFlSpotList;
    if (isHistoric) {
      _chartModelHistoric = chartModel;
    } else {
      _chartModelLast = chartModel;
    }
    notifyListeners();
  }

  Future<void> changeHistoricChartPeriod(String value) async {
    _chartModelHistoric.xAxisText = value;
    _actualSelectedHistoricPeriodFilter = value;
    _chartModelHistoric.isPeriod = false;
    HistoricFilterTypes historicFilterPeriod =
        historicFilters.keys.firstWhere((key) => historicFilters[key] == value);
    DateTime periodFilterDate;
    switch (historicFilterPeriod) {
      case HistoricFilterTypes.lastWeek:
        {
          periodFilterDate = DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .subtract(const Duration(days: 7));
          break;
        }
      case HistoricFilterTypes.lastMonth:
        {
          periodFilterDate = DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .subtract(const Duration(days: 30));
          break;
        }
      case HistoricFilterTypes.lastThreeMonths:
        {
          periodFilterDate = DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .subtract(const Duration(days: 91));
          break;
        }
      default:
        {
          periodFilterDate = DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .subtract(const Duration(days: 7));
          break;
        }
    }
    _chartModelHistoric.isDateSingleDay = false;
    _chartModelHistoric.selectedDate = periodFilterDate;
    _chartModelHistoric.chartData = _summaryModel.solarDataModel
        .where((solarSingleData) =>
            solarSingleData.solarDate.isAfter(periodFilterDate))
        .toList();
    await setSolarChartFilter(_chartModelHistoric.actualSelectedFilter,
        isHistoric: true);
  }

  Future<void> getHistoricDataCalendarFilter(DateTime date) async {
    if (_chartModelHistoric.isPeriod) {
      _chartModelHistoric.isDateSingleDay = false;
      _chartModelHistoric.xAxisText =
          "${DateFormat("dd.MM.yyyy").format(date)} - ${DateFormat("dd.MM.yyyy").format(DateTime.now())}";
      _chartModelHistoric.chartData = _summaryModel.solarDataModel
          .where((solarSingleData) => solarSingleData.solarDate.isAfter(date))
          .toList();
    } else {
      _chartModelHistoric.isDateSingleDay = true;
      _chartModelHistoric.xAxisText = DateFormat("dd.MM.yyyy").format(date);
      _chartModelHistoric.chartData = _summaryModel.solarDataModel
          .where((solarSingleData) =>
              solarSingleData.solarDate.year == date.year &&
              solarSingleData.solarDate.month == date.month &&
              solarSingleData.solarDate.day == date.day)
          .toList();
    }
    _chartModelHistoric.selectedDate = date;

    await setSolarChartFilter(_chartModelHistoric.actualSelectedFilter,
        isHistoric: true);
  }

  Future<void> getHistoricStats() async {
    _solarStatsModel = StatsModel(
        generatedPower: 0.0,
        averageVoltage: 0.0,
        averageCurrent: 0.0,
        averageTemperature: 0.0,
        averageHumidity: 0,
        averageLightIntensity: 0.0,
        lastdirection: "");
    if (_chartModelHistoric.chartData.isNotEmpty) {
      await Future.forEach(_chartModelHistoric.chartData, (solarDataModel) {
        _solarStatsModel.generatedPower += solarDataModel.power;
        _solarStatsModel.averageVoltage += solarDataModel.voltage;
        _solarStatsModel.averageCurrent += solarDataModel.current;
        _solarStatsModel.averageHumidity += solarDataModel.humidity;
        _solarStatsModel.averageTemperature += solarDataModel.temperature;
        _solarStatsModel.averageLightIntensity += solarDataModel.lightIntensity;
      });
      _solarStatsModel.lastdirection =
          _chartModelHistoric.chartData.last.direction;
      _solarStatsModel.averageVoltage = double.parse(
          (_solarStatsModel.averageVoltage /
                  _chartModelHistoric.chartData.length)
              .toStringAsFixed(2));
      _solarStatsModel.averageCurrent = double.parse(
          (_solarStatsModel.averageCurrent /
                  _chartModelHistoric.chartData.length)
              .toStringAsFixed(2));
      _solarStatsModel.averageHumidity = int.parse(
          (_solarStatsModel.averageHumidity /
                  _chartModelHistoric.chartData.length)
              .toStringAsFixed(0));
      _solarStatsModel.averageTemperature = double.parse(
          (_solarStatsModel.averageTemperature /
                  _chartModelHistoric.chartData.length)
              .toStringAsFixed(2));
      _solarStatsModel.averageLightIntensity = double.parse(
          (_solarStatsModel.averageLightIntensity /
                  _chartModelHistoric.chartData.length)
              .toStringAsFixed(2));

      //6 Liczba odczytów panelu na godzinę
      //1000 - przeliczenie Wh na kWh
      _solarStatsModel.generatedPower = double.parse(
          (_solarStatsModel.generatedPower /
                  SummaryModel.solarPanelSavesPerMinute /
                  1000)
              .toStringAsFixed(3));
    }
  }

  Future<void> getUserPositionForWeather() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    _userPosition = await Geolocator.getCurrentPosition();
  }

  Future<void> getWeather() async {
    try {
      _weather = await _weatherFactory.currentWeatherByLocation(
          _userPosition.latitude, _userPosition.longitude);
    } catch (_) {}
    notifyListeners();
  }
}
