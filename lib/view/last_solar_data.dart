import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/consumer/solar_consumer.dart';
import '../controller/solar_panel_research_controller.dart';
import '../model/solar_data_single_model.dart';
import 'chart_view.dart';

class LastSolarData extends StatefulWidget {
  const LastSolarData({super.key});

  @override
  State<LastSolarData> createState() => _LastSolarDataState();
}

class _LastSolarDataState extends State<LastSolarData> {
  late SolarPanelResearchController _solarPanelResearchController;

  @override
  void initState() {
    _solarPanelResearchController =
        context.read<SolarPanelResearchController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SolarConsumer<SolarPanelResearchController>(
      listen: true,
      builder: (context, model) {
        _solarPanelResearchController = model;
        // _solarPanelResearchController.setIsHistoricChartView = false;
        SolarDataModel lastSolarDataModel =
            _solarPanelResearchController.summaryModel.solarDataModel.last;
        return RefreshIndicator(
          onRefresh: () async {
            await _solarPanelResearchController.getSummaryDataFromPanel(
                context, mounted);
          },
          child: ListView(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.365,
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Card(
                              color: Colors.grey.shade50,
                              shadowColor: Colors.blue.shade400,
                              elevation: 15,
                              child: _solarPanelResearchController
                                      .isLastDataLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                "Ostatni odczyt z panelu",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                          ...getLastInfoSingleData(
                                              "Data i godzina: ",
                                              DateFormat("dd-MM-yyyy HH:mm")
                                                  .format(lastSolarDataModel
                                                      .solarDate),
                                              Icons.date_range,
                                              Colors.blue),
                                          ...getLastInfoSingleData(
                                              "Moc:",
                                              "${lastSolarDataModel.power} W",
                                              Icons.solar_power_outlined,
                                              Colors.green),
                                          ...getLastInfoSingleData(
                                              "Napięcie:",
                                              "${lastSolarDataModel.voltage} V",
                                              Icons.power_outlined,
                                              Colors.yellow.shade800),
                                          ...getLastInfoSingleData(
                                              "Natężenie:",
                                              "${lastSolarDataModel.current} A",
                                              Icons.electric_meter_outlined,
                                              Colors.red),
                                          ...getLastInfoSingleData(
                                              "Temperatura / Wilgotność:",
                                              "${lastSolarDataModel.temperature} °C / ${lastSolarDataModel.humidity}%",
                                              Icons.sunny_snowing,
                                              Colors.blue),
                                          ...getLastInfoSingleData(
                                              "Intensywność światła:",
                                              "${lastSolarDataModel.lightIntensity} lux",
                                              Icons.lightbulb_outline,
                                              Colors.yellow.shade700),
                                          ...getLastInfoSingleData(
                                              "Kierunek:",
                                              lastSolarDataModel.direction,
                                              Icons.north_east,
                                              Colors.blue),
                                          ...getLastInfoSingleData(
                                              "Kąt panelu:",
                                              "${lastSolarDataModel.solarAngle}°",
                                              Icons.perm_data_setting_outlined,
                                              Colors.blue),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      height: MediaQuery.of(context).size.height * 0.455,
                      child: Card(
                        elevation: 15,
                        child: _solarPanelResearchController.isLastDataLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : const ChartView(isHistoricView: false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> getLastInfoSingleData(
      String title, String content, IconData icon, Color color) {
    return [
      const SizedBox(
        height: 7,
      ),
      Row(
        children: [
          Icon(
            icon,
            size: 23,
            color: color,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            "$title $content",
            style: const TextStyle(fontSize: 15.5, color: Colors.black54),
          ),
        ],
      ),
    ];
  }
}
