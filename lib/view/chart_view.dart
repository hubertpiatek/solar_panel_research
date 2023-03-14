import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/consumer/solar_consumer.dart';
import 'package:solar_panel_research/controller/solar_panel_research_controller.dart';

class ChartView extends StatefulWidget {
  const ChartView({super.key});

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  late SolarPanelResearchController _solarPanelResearchController;
  @override
  void initState() {
    super.initState();
    _solarPanelResearchController =
        context.read<SolarPanelResearchController>();
  }

  @override
  Widget build(BuildContext context) {
    return SolarConsumer<SolarPanelResearchController>(
      listen: true,
      builder: (context, model) {
        _solarPanelResearchController = model;
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(8, 16, 25, 8),
              height: MediaQuery.of(context).size.height * 0.35,
              child: LineChart(
                LineChartData(
                    backgroundColor: Colors.indigo.shade500.withOpacity(0.9),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(),
                      topTitles: AxisTitles(),
                      // leftTitles: AxisTitles(
                      //     axisNameWidget: Container(
                      //       margin:
                      //           const EdgeInsets.only(
                      //               left: 40),
                      //       child: Text(
                      //           _solarPanelResearchController
                      //               .actualSelectedFilter),
                      //     ),
                      //     drawBehindEverything: true,
                      //     axisNameSize: 24,
                      //     sideTitles: SideTitles(
                      //         reservedSize: 26,
                      //         showTitles: true)),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Container(
                            margin: const EdgeInsets.fromLTRB(40, 12, 0, 0),
                            child: const Text("Czas [ t ]")),
                        drawBehindEverything: true,
                        axisNameSize: 30,
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 10:
                                return const Text("Maj");
                              default:
                                return Text(value.toString());
                            }
                          },
                        ),
                      ),
                    ),
                    minX: 6,
                    maxX: 22,
                    minY: _solarPanelResearchController.solarChartMinValue,
                    maxY: _solarPanelResearchController.solarChartMaxValue,
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
                        spots: [
                          ..._solarPanelResearchController.chartFlSpotList
                        ],
                        barWidth: 4,
                        color: Colors.yellow.shade700,
                        isCurved: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true, color: Colors.blue.withOpacity(0.4)),
                      )
                    ]),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: const Divider(
                height: 3,
                thickness: 1.5,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: DropdownButton<String>(
                isExpanded: true,
                alignment: AlignmentDirectional.center,
                hint: Text(
                  _solarPanelResearchController.actualSelectedFilter,
                  textAlign: TextAlign.center,
                ),
                items: SolarPanelResearchController.chartFilterInfo.values
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  _solarPanelResearchController
                      .setSolarChartFilter(value ?? "");
                },
              ),
            )
          ],
        );
      },
    );
  }
}
