import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/consumer/solar_consumer.dart';
import 'package:solar_panel_research/controller/solar_panel_research_controller.dart';
import '../model/chart_model.dart';

class ChartView extends StatefulWidget {
  final bool isHistoricView;
  const ChartView({super.key, required this.isHistoricView});

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
              margin: const EdgeInsets.fromLTRB(8, 16, 25, 4),
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
                      //       margin: const EdgeInsets.only(left: 40),
                      //       child: Text(_solarPanelResearchController
                      //           .chartModelHistoric.actualSelectedFilter),
                      //     ),
                      //     drawBehindEverything: true,
                      //     axisNameSize: 24,
                      //     sideTitles:
                      //         SideTitles(reservedSize: 26, showTitles: true)),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Container(
                            margin: widget.isHistoricView
                                ? const EdgeInsets.fromLTRB(30, 0, 0, 0)
                                : const EdgeInsets.fromLTRB(30, 12, 0, 0),
                            child: Text(
                              widget.isHistoricView
                                  ? _solarPanelResearchController
                                      .chartModelHistoric.xAxisText
                                  : _solarPanelResearchController
                                      .chartModelLast.xAxisText,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            )),
                        drawBehindEverything: true,
                        axisNameSize: 30,
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2,
                          getTitlesWidget: (value, meta) {
                            return getXAxisTextForChart(value, meta);
                          },
                        ),
                      ),
                    ),
                    minX: widget.isHistoricView
                        ? _solarPanelResearchController
                            .chartModelHistoric.solarChartMinXValue
                        : _solarPanelResearchController
                            .chartModelLast.solarChartMinXValue,
                    maxX: widget.isHistoricView
                        ? _solarPanelResearchController
                            .chartModelHistoric.solarChartMaxXValue
                        : _solarPanelResearchController
                            .chartModelLast.solarChartMaxXValue,
                    minY: widget.isHistoricView
                        ? _solarPanelResearchController
                            .chartModelHistoric.solarChartMinYValue
                        : _solarPanelResearchController
                            .chartModelLast.solarChartMinYValue,
                    maxY: widget.isHistoricView
                        ? _solarPanelResearchController
                            .chartModelHistoric.solarChartMaxYValue
                        : _solarPanelResearchController
                            .chartModelLast.solarChartMaxYValue,
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
                      widget.isHistoricView
                          ? LineChartBarData(
                              spots: [
                                ..._solarPanelResearchController
                                    .chartModelHistoric.chartFlSpotList
                              ],
                              barWidth: 4,
                              color: Colors.yellow.shade700,
                              isCurved: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.4)),
                            )
                          : LineChartBarData(
                              spots: [
                                ..._solarPanelResearchController
                                    .chartModelLast.chartFlSpotList
                              ],
                              barWidth: 4,
                              color: Colors.yellow.shade700,
                              isCurved: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.4)),
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
                  widget.isHistoricView
                      ? _solarPanelResearchController
                          .chartModelHistoric.actualSelectedFilter
                      : _solarPanelResearchController
                          .chartModelLast.actualSelectedFilter,
                  textAlign: TextAlign.center,
                ),
                items: ChartModel.chartFilterInfo.values.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  _solarPanelResearchController.setIsHistoricChartView =
                      widget.isHistoricView;
                  _solarPanelResearchController.setSolarChartFilter(value ?? "",
                      isHistoric: widget.isHistoricView);
                },
              ),
            )
          ],
        );
      },
    );
  }

  Widget getTextForPeriodFilter(double value) {
    Widget text;
    HistoricFilterTypes historicFilterPeriod =
        SolarPanelResearchController.historicFilters.keys.firstWhere((key) =>
            SolarPanelResearchController.historicFilters[key] ==
            _solarPanelResearchController.actualSelectedHistoricPeriodFilter);

    switch (historicFilterPeriod) {
      case HistoricFilterTypes.lastWeek:
        {
          String weekDay = DateFormat('EEEE', 'pl').format(
              DateTime.fromMillisecondsSinceEpoch((value * 100000).toInt()));
          text = Text(
            weekDay.toString().substring(0, 3),
            style: const TextStyle(fontWeight: FontWeight.w300),
          );
          return text;
        }
      case HistoricFilterTypes.lastMonth:
        {
          int monthDay =
              DateTime.fromMillisecondsSinceEpoch((value * 100000).toInt()).day;
          text = Text(
            monthDay.toString(),
            style: const TextStyle(fontWeight: FontWeight.w300),
          );
          return text;
        }
      case HistoricFilterTypes.lastThreeMonths:
        {
          String month = DateFormat('MMM', 'pl').format(
              DateTime.fromMillisecondsSinceEpoch((value * 100000).toInt()));
          text = Text(
            month.toString(),
            style: const TextStyle(fontWeight: FontWeight.w300),
          );
          return text;
        }
      default:
        {
          text = const Text("");
          break;
        }
    }
    return text;
  }

  Widget getXAxisTextForChart(double value, TitleMeta meta) {
    var hour =
        DateTime.fromMillisecondsSinceEpoch((value * 100000).toInt()).hour;
    switch (meta.axisPosition.toInt()) {
      case 1:
        if (!widget.isHistoricView ||
            _solarPanelResearchController.chartModelHistoric.isDateSingleDay) {
          return Text(hour.toString());
        } else if (widget.isHistoricView &&
            _solarPanelResearchController.chartModelHistoric.isPeriod) {
          return const Text("");
        } else {
          return getTextForPeriodFilter(value);
        }
      case 50:
        if (!widget.isHistoricView ||
            _solarPanelResearchController.chartModelHistoric.isDateSingleDay) {
          return Text(hour.toString());
        } else if (widget.isHistoricView &&
            _solarPanelResearchController.chartModelHistoric.isPeriod) {
          return const Text("");
        } else {
          return getTextForPeriodFilter(value);
        }
      case 100:
        if (!widget.isHistoricView ||
            _solarPanelResearchController.chartModelHistoric.isDateSingleDay) {
          return Text(hour.toString());
        } else if (widget.isHistoricView &&
            _solarPanelResearchController.chartModelHistoric.isPeriod) {
          return const Text("");
        } else {
          return getTextForPeriodFilter(value);
        }
      case 150:
        if (!widget.isHistoricView ||
            _solarPanelResearchController.chartModelHistoric.isDateSingleDay) {
          return Text(hour.toString());
        } else if (widget.isHistoricView &&
            _solarPanelResearchController.chartModelHistoric.isPeriod) {
          return const Text("");
        } else {
          return getTextForPeriodFilter(value);
        }
      case 200:
        if (!widget.isHistoricView ||
            _solarPanelResearchController.chartModelHistoric.isDateSingleDay) {
          return Text(hour.toString());
        } else if (widget.isHistoricView &&
            _solarPanelResearchController.chartModelHistoric.isPeriod) {
          return const Text("");
        } else {
          return getTextForPeriodFilter(value);
        }
      case 250:
        if (!widget.isHistoricView ||
            _solarPanelResearchController.chartModelHistoric.isDateSingleDay) {
          return Text(hour.toString());
        } else if (widget.isHistoricView &&
            _solarPanelResearchController.chartModelHistoric.isPeriod) {
          return const Text("");
        } else {
          return getTextForPeriodFilter(value);
        }
      case 280:
        if (!widget.isHistoricView ||
            _solarPanelResearchController.chartModelHistoric.isDateSingleDay) {
          return Text(hour.toString());
        } else if (widget.isHistoricView &&
            _solarPanelResearchController.chartModelHistoric.isPeriod) {
          return const Text("");
        } else {
          return getTextForPeriodFilter(value);
        }
      default:
        return const Text("");
    }
  }
}
