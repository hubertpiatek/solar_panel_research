import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/consumer/solar_consumer.dart';
import '../common/error_alert_dialog.dart';
import '../controller/solar_panel_research_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class LastSolarData extends StatefulWidget {
  const LastSolarData({super.key});

  @override
  State<LastSolarData> createState() => _LastSolarDataState();
}

class _LastSolarDataState extends State<LastSolarData> {
  late SolarPanelResearchController _solarPanelResearchController;
  final List<Color> gradientColors = [
    Colors.blue,
    const Color(0xff02d39a),
  ];
  @override
  void initState() {
    _solarPanelResearchController =
        context.read<SolarPanelResearchController>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getLastSolarData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SolarConsumer<SolarPanelResearchController>(
      listen: true,
      builder: (context, model) {
        _solarPanelResearchController = model;
        return SingleChildScrollView(
          //physics: const AlwaysScrollableScrollPhysics(),
          child: RefreshIndicator(
            onRefresh: () async {
              await getLastSolarData();
            },
            child: Stack(
              children: [
                Column(
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
                                              "06.03.2023 17:35:12",
                                              Icons.date_range,
                                              Colors.blue),
                                          ...getLastInfoSingleData(
                                              "Moc:",
                                              "35 W",
                                              Icons.solar_power_outlined,
                                              Colors.green),
                                          ...getLastInfoSingleData(
                                              "Napięcie:",
                                              "15 V",
                                              Icons.power_outlined,
                                              Colors.yellow.shade800),
                                          ...getLastInfoSingleData(
                                              "Natężenie:",
                                              "2.33 A",
                                              Icons.electric_meter_outlined,
                                              Colors.red),
                                          ...getLastInfoSingleData(
                                              "Temperatura / Wilgotność:",
                                              "15 °C / 100%",
                                              Icons.sunny_snowing,
                                              Colors.blue),
                                          ...getLastInfoSingleData(
                                              "Intensywność światła:",
                                              "40000 lux",
                                              Icons.lightbulb_outline,
                                              Colors.yellow.shade700),
                                          ...getLastInfoSingleData(
                                              "Kierunek:",
                                              "Południowy-Zachód",
                                              Icons.north_east,
                                              Colors.blue),
                                          ...getLastInfoSingleData(
                                              "Kąt panelu:",
                                              "35°",
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
                            : Column(
                                children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(8, 16, 32, 8),
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    child: LineChart(
                                      LineChartData(
                                          backgroundColor: Colors.indigo.shade500
                                              .withOpacity(0.9),
                                          titlesData: FlTitlesData(
                                              show: true,
                                              rightTitles: AxisTitles(),
                                              topTitles: AxisTitles(),
                                              leftTitles: AxisTitles(
                                                  axisNameWidget: Text(
                                                      _solarPanelResearchController
                                                          .actualSelectedFilter),
                                                  drawBehindEverything: true,
                                                  axisNameSize: 24,
                                                  sideTitles: SideTitles(
                                                      showTitles: true)),
                                              bottomTitles: AxisTitles(
                                                  axisNameWidget: Container(
                                                      margin: const EdgeInsets
                                                              .fromLTRB(
                                                          40, 12, 0, 0),
                                                      child: const Text(
                                                          "Czas [ t ]")),
                                                  drawBehindEverything: true,
                                                  axisNameSize: 30,
                                                  sideTitles: SideTitles(
                                                      showTitles: true))),
                                          minX: 6,
                                          maxX: 20,
                                          minY: 0,
                                          maxY: 6,
                                          gridData: FlGridData(
                                            show: true,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: Colors.blue.shade500,
                                                strokeWidth: 1,
                                              );
                                            },
                                            getDrawingVerticalLine: (value) {
                                              return FlLine(
                                                color: Colors.blue.shade500,
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          borderData: FlBorderData(show: true),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: const [
                                                FlSpot(6, 1),
                                                FlSpot(8.6, 2),
                                                FlSpot(12.9, 5),
                                                FlSpot(16.8, 2.5),
                                                FlSpot(19.2, 2.5),
                                                FlSpot(20, 2.5),
                                              ],
                                              barWidth: 4,
                                              color: Colors.yellow.shade700,
                                              isCurved: true,
                                              dotData: FlDotData(show: true),
                                              belowBarData: BarAreaData(
                                                  show: true,
                                                  color: gradientColors[0]
                                                      .withOpacity(0.4)),
                                            )
                                          ]),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: const Divider(
                                      height: 3,
                                      thickness: 1.5,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 50),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      alignment: AlignmentDirectional.center,
                                      hint: Text(
                                        _solarPanelResearchController
                                            .actualSelectedFilter,
                                        textAlign: TextAlign.center,
                                      ),
                                      items: SolarPanelResearchController
                                          .chartFilterInfo.values
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        _solarPanelResearchController
                                                .setActualSelectedFilter =
                                            value ?? "";
                                      },
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.37,
                    child: ListView()),
              ],
            ),
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
            width: 10,
          ),
          Text(
            "$title $content",
            style: const TextStyle(fontSize: 15.5, color: Colors.black54),
          ),
        ],
      ),
    ];
  }

  Future<void> getLastSolarData() async {
    try {
      await _solarPanelResearchController.getLastSolarData();
    } catch (error) {
      await showDialog(
        context: context,
        builder: (context) {
          return ErrorAlertDialog(errorContent: error.toString());
        },
      );
      _solarPanelResearchController.setIsLastDataLoading = false;
    }
  }
}
