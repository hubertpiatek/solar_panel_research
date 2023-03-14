import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:solar_panel_research/service/solar_panel_research_service.dart';
import 'package:weather/weather.dart';
import '../common/error_alert_dialog.dart';
import '../common/waiting_dialog.dart';
import '../model/solar_data_single_model.dart';
import '../model/summary_model.dart';
import 'package:geolocator/geolocator.dart';

enum ChartFilterTypes {
  power,
  voltage,
  current,
  temperature,
  humidity,
  lightIntensity,
  angle
}

class SolarPanelResearchController extends ChangeNotifier {
  static const Map<ChartFilterTypes, String> chartFilterInfo = {
    ChartFilterTypes.power: "Moc [ W ]",
    ChartFilterTypes.voltage: "Napięcie [ V ]",
    ChartFilterTypes.current: "Natężenie [ A ]",
    ChartFilterTypes.temperature: "Temperatura [ °C ]",
    ChartFilterTypes.humidity: "Wilgotność [ % ]",
    ChartFilterTypes.lightIntensity: "Intensywność [ Lux ]",
    ChartFilterTypes.angle: "Kąt panelu [ ° ]",
  };
  late String _actualSelectedFilter;
  late SolarPanelResearchService _solarPanelResearchService;
  late bool _isSummaryDataLoading;
  late bool _isLastDataLoading;
  late SummaryModel _summaryModel;
  late List<SolarDataModel> _lastDaySolarData;
  late bool _isAfterInit;
  late double _solarChartMinValue;
  late double _solarChartMaxValue;
  late List<FlSpot> _chartFlSpotList;
  late WeatherFactory _weatherFactory;
  late Position _userPosition;
  Weather? _weather;

  SolarPanelResearchController() {
    _solarPanelResearchService = SolarPanelResearchService();
    _isSummaryDataLoading = false;
    _isLastDataLoading = false;
    _lastDaySolarData = [];
    _summaryModel = SummaryModel(
      averageCurrent: 0.0,
      averageTemperature: 0.0,
      averageVoltage: 0.0,
      generatedPower: 0.0,
      solarDataModel: [],
    );
    _actualSelectedFilter = "Moc [ W ]";
    _isAfterInit = false;
    _solarChartMinValue = 0.0;
    _solarChartMaxValue = 120.0;
    _chartFlSpotList = [];
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
  double get solarChartMinValue {
    return _solarChartMinValue;
  }

  set setSolarChartMinValue(double solarChartMinValue) {
    _solarChartMinValue = solarChartMinValue;
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

  List<FlSpot> get chartFlSpotList {
    return _chartFlSpotList;
  }

  set setChartFlSpotList(List<FlSpot> chartFlSpotList) {
    _chartFlSpotList = chartFlSpotList;
  }

  double get solarChartMaxValue {
    return _solarChartMaxValue;
  }

  set setSolarChartMaxValue(double solarChartMaxValue) {
    _solarChartMaxValue = solarChartMaxValue;
  }

  String get actualSelectedFilter {
    return _actualSelectedFilter;
  }

  set setActualSelectedFilter(String actualSelectedFilter) {
    _actualSelectedFilter = actualSelectedFilter;
    notifyListeners();
  }

  List<SolarDataModel> get solarAllData {
    return _lastDaySolarData;
  }

  set setSolarAllData(List<SolarDataModel> solarAllData) {
    _lastDaySolarData = solarAllData;
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
    notifyListeners();
  }

  Future<void> getSummaryData() async {
    setIsSummaryDataLoading = true;
    _summaryModel = await _solarPanelResearchService.getSummaryData();

    setIsSummaryDataLoading = false;
    // _lastDaySolarData = _summaryModel.solarDataModel
    //     .where((solarSingleData) =>
    //         solarSingleData.solarDate.year ==
    //             _summaryModel.solarDataModel.last.solarDate.year &&
    //         solarSingleData.solarDate.month ==
    //             _summaryModel.solarDataModel.last.solarDate.month &&
    //         solarSingleData.solarDate.day ==
    //             _summaryModel.solarDataModel.last.solarDate.day)
    //     .toList();
    _lastDaySolarData = _summaryModel.solarDataModel
        .where((solarSingleData) =>
            solarSingleData.solarDate.year == DateTime(2022, 10, 1).year &&
            solarSingleData.solarDate.month == DateTime(2022, 10, 1).month &&
            solarSingleData.solarDate.day == DateTime(2022, 10, 1).day)
        .toList();
    setSolarChartFilter(_actualSelectedFilter);
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

  void setSolarChartFilter(String value) {
    _actualSelectedFilter = value;
    List<FlSpot> chartFlSpotList = [];
    ChartFilterTypes chartFiler =
        chartFilterInfo.keys.firstWhere((key) => chartFilterInfo[key] == value);
    switch (chartFiler) {
      case ChartFilterTypes.power:
        _solarChartMinValue = 0;
        _solarChartMaxValue = 120;
        for (var singleSolarData in _lastDaySolarData) {
          chartFlSpotList.add(FlSpot(
              singleSolarData.solarDate.hour.toDouble() +
                  singleSolarData.solarDate.minute.toDouble() / 60 +
                  singleSolarData.solarDate.second.toDouble() / 3600,
              singleSolarData.power));
        }
        break;
      case ChartFilterTypes.voltage:
        _solarChartMinValue = 0;
        _solarChartMaxValue = 24;
        for (var singleSolarData in _lastDaySolarData) {
          chartFlSpotList.add(FlSpot(
              singleSolarData.solarDate.hour.toDouble() +
                  singleSolarData.solarDate.minute.toDouble() / 60 +
                  singleSolarData.solarDate.second.toDouble() / 3600,
              singleSolarData.voltage));
        }
        break;
      case ChartFilterTypes.current:
        _solarChartMinValue = 0;
        _solarChartMaxValue = 6;
        for (var singleSolarData in _lastDaySolarData) {
          chartFlSpotList.add(FlSpot(
              singleSolarData.solarDate.hour.toDouble() +
                  singleSolarData.solarDate.minute.toDouble() / 60 +
                  singleSolarData.solarDate.second.toDouble() / 3600,
              singleSolarData.current));
        }
        break;
      case ChartFilterTypes.temperature:
        _solarChartMinValue = 0;
        _solarChartMaxValue = 40;
        for (var singleSolarData in _lastDaySolarData) {
          chartFlSpotList.add(FlSpot(
              singleSolarData.solarDate.hour.toDouble() +
                  singleSolarData.solarDate.minute.toDouble() / 60 +
                  singleSolarData.solarDate.second.toDouble() / 3600,
              singleSolarData.temperature));
        }
        break;
      case ChartFilterTypes.humidity:
        _solarChartMinValue = 0;
        _solarChartMaxValue = 100;
        for (var singleSolarData in _lastDaySolarData) {
          chartFlSpotList.add(FlSpot(
              singleSolarData.solarDate.hour.toDouble() +
                  singleSolarData.solarDate.minute.toDouble() / 60 +
                  singleSolarData.solarDate.second.toDouble() / 3600,
              singleSolarData.humidity.toDouble()));
        }
        break;
      case ChartFilterTypes.lightIntensity:
        _solarChartMinValue = 0;
        _solarChartMaxValue = 65000;
        for (var singleSolarData in _lastDaySolarData) {
          chartFlSpotList.add(FlSpot(
              singleSolarData.solarDate.hour.toDouble() +
                  singleSolarData.solarDate.minute.toDouble() / 60 +
                  singleSolarData.solarDate.second.toDouble() / 3600,
              singleSolarData.lightIntensity));
        }
        break;
      case ChartFilterTypes.angle:
        _solarChartMinValue = 0;
        _solarChartMaxValue = 50;
        for (var singleSolarData in _lastDaySolarData) {
          chartFlSpotList.add(FlSpot(
              singleSolarData.solarDate.hour.toDouble() +
                  singleSolarData.solarDate.minute.toDouble() / 60 +
                  singleSolarData.solarDate.second.toDouble() / 3600,
              singleSolarData.solarAngle.toDouble()));
        }
        break;
      default:
        _solarChartMinValue = 0;
        _solarChartMaxValue = 120;
        for (var singleSolarData in _lastDaySolarData) {
          chartFlSpotList.add(FlSpot(
              singleSolarData.solarDate.hour.toDouble() +
                  singleSolarData.solarDate.minute.toDouble() / 60 +
                  singleSolarData.solarDate.second.toDouble() / 3600,
              singleSolarData.power));
        }
        break;
    }
    _chartFlSpotList = chartFlSpotList;
    notifyListeners();
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
