import 'package:flutter/material.dart';
import 'package:solar_panel_research/service/solar_panel_research_service.dart';

import '../model/solar_data_single_model.dart';
import '../model/summary_model.dart';

enum ChartFilterTypes {
  power,
  voltage,
  amper,
  temperature,
  humidity,
  lightIntensity,
  angle
}

class SolarPanelResearchController extends ChangeNotifier {
  static const Map<ChartFilterTypes, String> chartFilterInfo = {
    ChartFilterTypes.power: "Moc [ W ]",
    ChartFilterTypes.voltage: "Napięcie [ V ]",
    ChartFilterTypes.amper: "Natężenie [ A ]",
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
  late List<SolarDataModel> _solarAllData;

  SolarPanelResearchController() {
    _solarPanelResearchService = SolarPanelResearchService();
    _isSummaryDataLoading = false;
    _isLastDataLoading = false;
    _solarAllData = [];
    _summaryModel = SummaryModel(
      averageCurrent: 0.0,
      averageTemperature: 0.0,
      averageVoltage: 0.0,
      generatedPower: 0.0,
      solarDataModel: [],
    );
    _actualSelectedFilter = "Moc [ W ]";
  }

  String get actualSelectedFilter {
    return _actualSelectedFilter;
  }

  set setActualSelectedFilter(String actualSelectedFilter) {
    _actualSelectedFilter = actualSelectedFilter;
    notifyListeners();
  }

  List<SolarDataModel> get solarAllData {
    return _solarAllData;
  }

  set setSolarAllData(List<SolarDataModel> solarAllData) {
    _solarAllData = solarAllData;
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
  }

  Future<void> getLastSolarData() async {
    setIsLastDataLoading = true;
    await _solarPanelResearchService.getLastSolarData();
    setIsLastDataLoading = false;
  }
}
