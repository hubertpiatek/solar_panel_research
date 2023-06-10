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

  static const Map<int, String> listOfPanels = {
    0: "Panel polikrystaliczny 50W",
    1: "Panel monokrystaliczny 50W",
    2: "Panel polikrystaliczny 110W",
  };

  static Map<int, bool> enabledPanels = {
    0: true,
    1: true,
    2: false,
  };

  static Map<int, Color> chartColors = {
    0: Colors.blue.withOpacity(0.3),
    1: Colors.green.withOpacity(0.4),
    2: const Color.fromRGBO(39, 55, 70, 0.4)
  };

  static Map<int, Color> chartLinesColors = {
    0: const Color.fromRGBO(255, 146, 10, 1),
    1: Colors.yellow,
    2: Colors.green,
  };

  static const Map<int, String> panelsEndpoints = {
    0: "solarDataFromSunFinalNew",
    1: "solarDataFromSunFinalNew2",
    2: "solarDataFromSunFinal",
  };

  static int getEnabledPanelsAmount() {
    return enabledPanels.values.where((element) => element).length;
  }

  late List<ChartModel> _chartModelLast;
  late List<ChartModel> _chartModelHistoric;
  late String _actualSelectedHistoricPeriodFilter;
  late SolarPanelResearchService _solarPanelResearchService;
  late bool _isSummaryDataLoading;
  late bool _isLastDataLoading;
  late bool _isHistoricChartView;
  late List<SummaryModel> _summaryModel;
  late SummaryModel _summaryModelFinal;
  late bool _isAfterInit;
  late WeatherFactory _weatherFactory;
  late Position _userPosition;
  late List<StatsModel> _solarStatsModel;
  Weather? _weather;

  SolarPanelResearchController() {
    _solarPanelResearchService = SolarPanelResearchService();
    _isSummaryDataLoading = false;
    _isLastDataLoading = false;
    _isHistoricChartView = false;
    _chartModelLast = [];
    _chartModelHistoric = [];
    _summaryModel = [];
    _summaryModelFinal = SummaryModel(
        generatedPower: 0.0,
        averageVoltage: 00,
        averageCurrent: 0.0,
        averageTemperature: 0.0,
        solarDataModel: []);
    _solarStatsModel = [];
    panelsEndpoints.forEach((index, value) {
      _chartModelLast.add(ChartModel(
        chartData: [],
        chartFlSpotList: [],
      ));
      ChartModel.chartAxisModelLast.selectedDate = DateTime(2022, 10, 1);
      ChartModel.chartAxisModelLast.isDateSingleDay = true;
      ChartModel.chartAxisModelLast.isPeriod = false;
      ChartModel.chartAxisModelLast.xAxisText = "Czas [ h ]";
      ChartModel.chartAxisModelLast.solarChartMinYValue = 0.0;
      ChartModel.chartAxisModelLast.solarChartMaxYValue = 60.0;
      ChartModel.chartAxisModelLast.solarChartMinXValue = 6.0;
      ChartModel.chartAxisModelLast.solarChartMaxXValue = 22.0;
      _chartModelHistoric.add(ChartModel(
        chartData: [],
        chartFlSpotList: [],
      ));
      ChartModel.chartAxisModelHistoric.selectedDate = DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .subtract(const Duration(days: 7));
      ChartModel.chartAxisModelHistoric.isDateSingleDay = false;
      ChartModel.chartAxisModelHistoric.isPeriod = false;
      ChartModel.chartAxisModelHistoric.xAxisText =
          historicFilters[HistoricFilterTypes.lastWeek]!;
      ChartModel.chartAxisModelHistoric.solarChartMinYValue = 0.0;
      ChartModel.chartAxisModelHistoric.solarChartMaxYValue = 60.0;
      ChartModel.chartAxisModelHistoric.solarChartMinXValue = 6.0;
      ChartModel.chartAxisModelHistoric.solarChartMaxXValue = 22.0;
      _summaryModel.add(SummaryModel(
        averageCurrent: 0.0,
        averageTemperature: 0.0,
        averageVoltage: 0.0,
        generatedPower: 0.0,
        solarDataModel: [],
      ));
      _solarStatsModel.add(StatsModel(
          generatedPower: 0.0,
          averageVoltage: 0.0,
          averageCurrent: 0.0,
          averageTemperature: 0.0,
          averageHumidity: 0,
          averageLightIntensity: 0.0,
          lastdirection: ""));
    });
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

  List<ChartModel> get chartModelLast {
    return _chartModelLast;
  }

  set setChartModelLast(List<ChartModel> chartModelLast) {
    _chartModelLast = chartModelLast;
  }

  List<StatsModel> get solarStatsModel {
    return _solarStatsModel;
  }

  set setSolarStatsModel(List<StatsModel> solarStatsModel) {
    _solarStatsModel = solarStatsModel;
  }

  bool get isHistoricChartView {
    return _isHistoricChartView;
  }

  set setIsHistoricChartView(bool isHistoricChartView) {
    _isHistoricChartView = isHistoricChartView;
  }

  List<ChartModel> get chartModelHistoric {
    return _chartModelHistoric;
  }

  set setChartModelHistoric(List<ChartModel> chartModelHistoric) {
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

  List<SummaryModel> get summaryModel {
    return _summaryModel;
  }

  set setSummaryModel(List<SummaryModel> summaryModel) {
    _summaryModel = summaryModel;
  }

  SummaryModel get summaryModelFinal {
    return _summaryModelFinal;
  }

  set setSummaryModelFinal(SummaryModel summaryModelFinal) {
    _summaryModelFinal = summaryModelFinal;
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

  void getSummaryDataFinal() {
    int enabledPanelsAmount = getEnabledPanelsAmount();
    _summaryModelFinal.generatedPower = 0.0;
    _summaryModelFinal.averageVoltage = 0.0;
    _summaryModelFinal.averageCurrent = 0.0;
    _summaryModelFinal.averageTemperature = 0.0;
    enabledPanels.forEach((index, isEnabled) {
      if (isEnabled) {
        _summaryModelFinal.generatedPower +=
            _summaryModel[index].generatedPower;
        _summaryModelFinal.averageVoltage +=
            _summaryModel[index].averageVoltage;
        _summaryModelFinal.averageCurrent +=
            _summaryModel[index].averageCurrent;
        _summaryModelFinal.averageTemperature +=
            _summaryModel[index].averageTemperature;
      }
    });
    _summaryModelFinal.generatedPower =
        double.parse((_summaryModelFinal.generatedPower).toStringAsFixed(2));
    if (enabledPanelsAmount > 0) {
      _summaryModelFinal.averageCurrent = double.parse(
          (_summaryModelFinal.averageCurrent / enabledPanelsAmount)
              .toStringAsFixed(2));
      _summaryModelFinal.averageVoltage = double.parse(
          (_summaryModelFinal.averageVoltage / enabledPanelsAmount)
              .toStringAsFixed(2));
      _summaryModelFinal.averageTemperature = double.parse(
          (_summaryModelFinal.averageTemperature / enabledPanelsAmount)
              .toStringAsFixed(2));
    }
  }

  void reloadDataOnPanelAction(int index) {
    getSummaryDataFinal();
    notifyListeners();
  }

  Future<void> getSummaryData() async {
    setIsSummaryDataLoading = true;
    //Pobierz ostatnie dane i pokaż na wykresie
    await Future.forEach(panelsEndpoints.keys, (index) async {
      _summaryModel[index] = await _solarPanelResearchService
          .getSummaryData(panelsEndpoints[index]!);

      _chartModelLast[index].chartData = _summaryModel[index]
          .solarDataModel
          .where((solarSingleData) =>
              solarSingleData.solarDate.year == DateTime.now().year &&
              solarSingleData.solarDate.month == DateTime.now().month &&
              solarSingleData.solarDate.day == DateTime.now().day)
          .toList();
      await setSolarChartFilter(
          ChartModel.chartAxisModelLast.actualSelectedFilter,
          isHistoric: false);
      //Pobierz dane historyczne i pokaż na wykresie
      if (ChartModel.chartAxisModelHistoric.isDateSingleDay) {
        _chartModelHistoric[index].chartData = _summaryModel[index]
            .solarDataModel
            .where((solarSingleData) =>
                solarSingleData.solarDate.year ==
                    ChartModel.chartAxisModelHistoric.selectedDate.year &&
                solarSingleData.solarDate.month ==
                    ChartModel.chartAxisModelHistoric.selectedDate.month &&
                solarSingleData.solarDate.day ==
                    ChartModel.chartAxisModelHistoric.selectedDate.day)
            .toList();
      } else {
        _chartModelHistoric[index].chartData = _summaryModel[index]
            .solarDataModel
            .where((solarSingleData) => solarSingleData.solarDate
                .isAfter(ChartModel.chartAxisModelHistoric.selectedDate))
            .toList();
      }
      await setSolarChartFilter(
          ChartModel.chartAxisModelHistoric.actualSelectedFilter,
          isHistoric: true);
    });
    getSummaryDataFinal();
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

  double maxXValueForChart({required bool isHistoric}) {
    List<double> maxValues = [];
    double maxValue = 0.0;
    panelsEndpoints.forEach((index, endpoint) async {
      ChartModel chartModel =
          isHistoric ? _chartModelHistoric[index] : _chartModelLast[index];
      try {
        maxValues.add(
            chartModel.chartData.last.solarDate.millisecondsSinceEpoch /
                100000);
      } catch (_) {}
    });
    if (maxValues.isNotEmpty) maxValue = maxValues[0];
    for (var element in maxValues) {
      if (element > maxValue) maxValue = element;
    }
    return maxValue;
  }

  double minXValueForChart({required bool isHistoric}) {
    List<double> minValues = [];
    double minValue = 0.0;
    panelsEndpoints.forEach((index, endpoint) async {
      ChartModel chartModel =
          isHistoric ? _chartModelHistoric[index] : _chartModelLast[index];
      try {
        minValues.add(
            chartModel.chartData.first.solarDate.millisecondsSinceEpoch /
                100000);
      } catch (_) {}
    });
    if (minValues.isNotEmpty) minValue = minValues[0];
    for (var element in minValues) {
      if (element < minValue) minValue = element;
    }
    return minValue;
  }

  Future<void> setSolarChartFilter(String value,
      {required bool isHistoric}) async {
    panelsEndpoints.forEach((index, endpoint) async {
      ChartModel chartModel =
          isHistoric ? _chartModelHistoric[index] : _chartModelLast[index];
      if (isHistoric) {
        ChartModel.chartAxisModelHistoric.actualSelectedFilter = value;
      } else {
        ChartModel.chartAxisModelLast.actualSelectedFilter = value;
      }
      List<FlSpot> chartFlSpotList = [];
      chartModel.chartFlSpotList = [];
      if (isHistoric) {
        ChartModel.chartAxisModelHistoric.solarChartMinXValue = 0.0;
        ChartModel.chartAxisModelHistoric.solarChartMaxXValue = 0.0;
      } else {
        ChartModel.chartAxisModelLast.solarChartMinXValue = 0.0;
        ChartModel.chartAxisModelLast.solarChartMaxXValue = 0.0;
      }
      if (chartModel.chartData.isNotEmpty) {
        ChartFilterTypes chartFilter = ChartModel.chartFilterInfo.keys
            .firstWhere((key) => ChartModel.chartFilterInfo[key] == value);
        if (isHistoric) {
          ChartModel.chartAxisModelHistoric.solarChartMinXValue =
              minXValueForChart(isHistoric: isHistoric);
          ChartModel.chartAxisModelHistoric.solarChartMaxXValue =
              maxXValueForChart(isHistoric: isHistoric);
        } else {
          ChartModel.chartAxisModelLast.solarChartMinXValue =
              minXValueForChart(isHistoric: isHistoric);
          ChartModel.chartAxisModelLast.solarChartMaxXValue =
              maxXValueForChart(isHistoric: isHistoric);
        }
        switch (chartFilter) {
          case ChartFilterTypes.power:
            if (isHistoric) {
              ChartModel.chartAxisModelHistoric.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelHistoric.solarChartMaxYValue = 60.0;
            } else {
              ChartModel.chartAxisModelLast.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelLast.solarChartMaxYValue = 60.0;
            }
            for (var singleSolarData in chartModel.chartData) {
              chartFlSpotList.add(FlSpot(
                  singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                  singleSolarData.power));
            }
            break;
          case ChartFilterTypes.voltage:
            if (isHistoric) {
              ChartModel.chartAxisModelHistoric.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelHistoric.solarChartMaxYValue = 20.0;
            } else {
              ChartModel.chartAxisModelLast.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelLast.solarChartMaxYValue = 20.0;
            }
            for (var singleSolarData in chartModel.chartData) {
              chartFlSpotList.add(FlSpot(
                  singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                  singleSolarData.voltage));
            }
            break;
          case ChartFilterTypes.current:
            if (isHistoric) {
              ChartModel.chartAxisModelHistoric.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelHistoric.solarChartMaxYValue = 4.0;
            } else {
              ChartModel.chartAxisModelLast.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelLast.solarChartMaxYValue = 4.0;
            }
            for (var singleSolarData in chartModel.chartData) {
              chartFlSpotList.add(FlSpot(
                  singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                  singleSolarData.current));
            }
            break;
          case ChartFilterTypes.temperature:
            if (isHistoric) {
              ChartModel.chartAxisModelHistoric.solarChartMinYValue = -5.0;
              ChartModel.chartAxisModelHistoric.solarChartMaxYValue = 50.0;
            } else {
              ChartModel.chartAxisModelLast.solarChartMinYValue = -5.0;
              ChartModel.chartAxisModelLast.solarChartMaxYValue = 50.0;
            }
            for (var singleSolarData in chartModel.chartData) {
              chartFlSpotList.add(FlSpot(
                  singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                  singleSolarData.temperature));
            }
            break;
          case ChartFilterTypes.humidity:
            if (isHistoric) {
              ChartModel.chartAxisModelHistoric.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelHistoric.solarChartMaxYValue = 100.0;
            } else {
              ChartModel.chartAxisModelLast.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelLast.solarChartMaxYValue = 100.0;
            }
            for (var singleSolarData in chartModel.chartData) {
              chartFlSpotList.add(FlSpot(
                  singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                  singleSolarData.humidity.toDouble()));
            }
            break;
          case ChartFilterTypes.lightIntensity:
            if (isHistoric) {
              ChartModel.chartAxisModelHistoric.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelHistoric.solarChartMaxYValue = 120000.0;
            } else {
              ChartModel.chartAxisModelLast.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelLast.solarChartMaxYValue = 120000.0;
            }
            for (var singleSolarData in chartModel.chartData) {
              chartFlSpotList.add(FlSpot(
                  singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                  singleSolarData.lightIntensity));
            }
            break;
          case ChartFilterTypes.angle:
            if (isHistoric) {
              ChartModel.chartAxisModelHistoric.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelHistoric.solarChartMaxYValue = 50.0;
            } else {
              ChartModel.chartAxisModelLast.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelLast.solarChartMaxYValue = 50.0;
            }
            for (var singleSolarData in chartModel.chartData) {
              chartFlSpotList.add(FlSpot(
                  singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                  singleSolarData.solarAngle.toDouble()));
            }
            break;
          default:
            if (isHistoric) {
              ChartModel.chartAxisModelHistoric.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelHistoric.solarChartMaxYValue = 60.0;
            } else {
              ChartModel.chartAxisModelLast.solarChartMinYValue = 0.0;
              ChartModel.chartAxisModelLast.solarChartMaxYValue = 60.0;
            }
            for (var singleSolarData in chartModel.chartData) {
              chartFlSpotList.add(FlSpot(
                  singleSolarData.solarDate.millisecondsSinceEpoch / 100000,
                  singleSolarData.power));
            }
            break;
        }
      }

      chartModel.chartFlSpotList = chartFlSpotList;
      if (isHistoric) {
        _chartModelHistoric[index] = chartModel;
      } else {
        _chartModelLast[index] = chartModel;
      }
    });
    if (isHistoric) {
      await getHistoricStats();
    }
    notifyListeners();
  }

  Future<void> changeHistoricChartPeriod(String value) async {
    panelsEndpoints.forEach((index, _) async {
      ChartModel.chartAxisModelHistoric.xAxisText = value;
      _actualSelectedHistoricPeriodFilter = value;
      ChartModel.chartAxisModelHistoric.isPeriod = false;
      HistoricFilterTypes historicFilterPeriod = historicFilters.keys
          .firstWhere((key) => historicFilters[key] == value);
      DateTime periodFilterDate;
      switch (historicFilterPeriod) {
        case HistoricFilterTypes.lastWeek:
          {
            periodFilterDate = DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day)
                .subtract(const Duration(days: 7));
            break;
          }
        case HistoricFilterTypes.lastMonth:
          {
            periodFilterDate = DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day)
                .subtract(const Duration(days: 30));
            break;
          }
        case HistoricFilterTypes.lastThreeMonths:
          {
            periodFilterDate = DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day)
                .subtract(const Duration(days: 91));
            break;
          }
        default:
          {
            periodFilterDate = DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day)
                .subtract(const Duration(days: 7));
            break;
          }
      }
      ChartModel.chartAxisModelHistoric.isDateSingleDay = false;
      ChartModel.chartAxisModelHistoric.selectedDate = periodFilterDate;
      _chartModelHistoric[index].chartData = _summaryModel[index]
          .solarDataModel
          .where((solarSingleData) =>
              solarSingleData.solarDate.isAfter(periodFilterDate))
          .toList();
    });
    await setSolarChartFilter(
        ChartModel.chartAxisModelHistoric.actualSelectedFilter,
        isHistoric: true);
  }

  Future<void> getHistoricDataCalendarFilter(DateTime date) async {
    panelsEndpoints.forEach((index, value) async {
      if (ChartModel.chartAxisModelHistoric.isPeriod) {
        ChartModel.chartAxisModelHistoric.isDateSingleDay = false;
        ChartModel.chartAxisModelHistoric.xAxisText =
            "${DateFormat("dd.MM.yyyy").format(date)} - ${DateFormat("dd.MM.yyyy").format(DateTime.now())}";
        "${DateFormat("dd.MM.yyyy").format(date)} - ${DateFormat("dd.MM.yyyy").format(DateTime.now())}";
        _chartModelHistoric[index].chartData = _summaryModel[index]
            .solarDataModel
            .where((solarSingleData) => solarSingleData.solarDate.isAfter(date))
            .toList();
      } else {
        ChartModel.chartAxisModelHistoric.isDateSingleDay = true;
        ChartModel.chartAxisModelHistoric.xAxisText =
            DateFormat("dd.MM.yyyy").format(date);
        _chartModelHistoric[index].chartData = _summaryModel[index]
            .solarDataModel
            .where((solarSingleData) =>
                solarSingleData.solarDate.year == date.year &&
                solarSingleData.solarDate.month == date.month &&
                solarSingleData.solarDate.day == date.day)
            .toList();
      }
      ChartModel.chartAxisModelHistoric.selectedDate = date;
    });
    await setSolarChartFilter(
        ChartModel.chartAxisModelHistoric.actualSelectedFilter,
        isHistoric: true);
    notifyListeners();
  }

  Future<void> getHistoricStats() async {
    panelsEndpoints.forEach((index, value) async {
      _solarStatsModel[index] = StatsModel(
          generatedPower: 0.0,
          averageVoltage: 0.0,
          averageCurrent: 0.0,
          averageTemperature: 0.0,
          averageHumidity: 0,
          averageLightIntensity: 0.0,
          lastdirection: "");
      if (_chartModelHistoric[index].chartData.isNotEmpty) {
        await Future.forEach(_chartModelHistoric[index].chartData,
            (solarDataModel) {
          _solarStatsModel[index].generatedPower += solarDataModel.power;
          _solarStatsModel[index].averageVoltage += solarDataModel.voltage;
          _solarStatsModel[index].averageCurrent += solarDataModel.current;
          _solarStatsModel[index].averageHumidity += solarDataModel.humidity;
          _solarStatsModel[index].averageTemperature +=
              solarDataModel.temperature;
          _solarStatsModel[index].averageLightIntensity +=
              solarDataModel.lightIntensity;
        });
        try {
          _solarStatsModel[index].lastdirection =
              _chartModelHistoric[index].chartData.last.direction;
        } catch (_) {}

        _solarStatsModel[index].averageVoltage = double.parse(
            (_solarStatsModel[index].averageVoltage /
                    _chartModelHistoric[index].chartData.length)
                .toStringAsFixed(2));
        _solarStatsModel[index].averageCurrent = double.parse(
            (_solarStatsModel[index].averageCurrent /
                    _chartModelHistoric[index].chartData.length)
                .toStringAsFixed(2));
        try {
          _solarStatsModel[index].averageHumidity = int.parse(
              (_solarStatsModel[index].averageHumidity /
                      _chartModelHistoric[index].chartData.length)
                  .toStringAsFixed(0));
        } catch (_) {
          _solarStatsModel[index].averageHumidity = 0;
        }

        _solarStatsModel[index].averageTemperature = double.parse(
            (_solarStatsModel[index].averageTemperature /
                    _chartModelHistoric[index].chartData.length)
                .toStringAsFixed(2));
        _solarStatsModel[index].averageLightIntensity = double.parse(
            (_solarStatsModel[index].averageLightIntensity /
                    _chartModelHistoric[index].chartData.length)
                .toStringAsFixed(2));

        //6 Liczba odczytów panelu na godzinę
        //1000 - przeliczenie Wh na kWh
        _solarStatsModel[index].generatedPower = double.parse(
            (_solarStatsModel[index].generatedPower /
                    SummaryModel.solarPanelSavesPerMinute /
                    1000)
                .toStringAsFixed(3));
      }
    });
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
