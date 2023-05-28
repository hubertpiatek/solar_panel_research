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
                      leftTitles: AxisTitles(
                          drawBehindEverything: true,
                          sideTitles: SideTitles(
                            reservedSize: 45,
                            showTitles: true,
                            interval: getIntervalForYAxis(),
                          )),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Container(
                            margin: widget.isHistoricView
                                ? const EdgeInsets.fromLTRB(30, 0, 0, 0)
                                : const EdgeInsets.fromLTRB(30, 12, 0, 0),
                            child: Text(
                              widget.isHistoricView
                                  ? ChartModel.chartAxisModelHistoric.xAxisText
                                  : ChartModel.chartAxisModelLast.xAxisText,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            )),
                        drawBehindEverything: true,
                        axisNameSize: 30,
                        sideTitles: SideTitles(
                          showTitles: true,
                          //  interval: getInterval(),
                          getTitlesWidget: (value, meta) {
                            return getXAxisTextForChart(value, meta);
                          },
                        ),
                      ),
                    ),
                    minX: _solarPanelResearchController.minXValueForChart(
                        isHistoric: widget.isHistoricView),
                    maxX: _solarPanelResearchController.maxXValueForChart(
                        isHistoric: widget.isHistoricView),
                    minY: widget.isHistoricView
                        ? ChartModel.chartAxisModelHistoric.solarChartMinYValue
                        : ChartModel.chartAxisModelLast.solarChartMinYValue,
                    maxY: widget.isHistoricView
                        ? ChartModel.chartAxisModelHistoric.solarChartMaxYValue
                        : ChartModel.chartAxisModelLast.solarChartMaxYValue,
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.blue.shade500,
                          strokeWidth: 0.7,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.blue.shade500,
                          strokeWidth: 0.7,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      ...getLineBarsData(),
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
                      ? ChartModel.chartAxisModelHistoric.actualSelectedFilter
                      : ChartModel.chartAxisModelLast.actualSelectedFilter,
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
    if (meta.min == value || meta.max == value) {
      return const Text("");
    }
    if (!widget.isHistoricView ||
        ChartModel.chartAxisModelHistoric.isDateSingleDay) {
      return Text(hour.toString());
    } else if (widget.isHistoricView &&
        ChartModel.chartAxisModelHistoric.isPeriod) {
      return const Text("");
    } else {
      return getTextForPeriodFilter(value);
    }
  }

  double getInterval() {
    double minX = widget.isHistoricView
        ? ChartModel.chartAxisModelHistoric.solarChartMinXValue
        : ChartModel.chartAxisModelLast.solarChartMinXValue;
    double maxX = widget.isHistoricView
        ? ChartModel.chartAxisModelHistoric.solarChartMaxXValue
        : ChartModel.chartAxisModelLast.solarChartMaxXValue;
    double interval = (maxX - minX) / 5.7;
    if (interval == 0.0) {
      return 70;
    }
    return (maxX - minX) / 5.7;
  }

  double? getIntervalForYAxis() {
    ChartFilterTypes chartFilter = ChartModel.chartFilterInfo.keys.firstWhere(
        (key) =>
            ChartModel.chartFilterInfo[key] ==
            (widget.isHistoricView
                ? ChartModel.chartAxisModelHistoric.actualSelectedFilter
                : ChartModel.chartAxisModelLast.actualSelectedFilter));
    switch (chartFilter) {
      case ChartFilterTypes.power:
        return 20;
      case ChartFilterTypes.voltage:
        return 4;
      case ChartFilterTypes.current:
        return 1;
      case ChartFilterTypes.temperature:
        return 10;
      case ChartFilterTypes.humidity:
        return 20;
      case ChartFilterTypes.lightIntensity:
        return 10000;
      case ChartFilterTypes.angle:
        return 10;
      default:
        return null;
    }
  }

  List<LineChartBarData> getLineBarsData() {
    List<LineChartBarData> lineBarsData = [];
    SolarPanelResearchController.enabledPanels.forEach((index, isEnabled) {
      if (isEnabled) {
        if (widget.isHistoricView) {
          lineBarsData.add(LineChartBarData(
            spots: [
              ..._solarPanelResearchController
                  .chartModelHistoric[index].chartFlSpotList,
            ],
            barWidth: 2,
            color: SolarPanelResearchController.chartLinesColors[index],
            curveSmoothness: 0.1,
            isCurved: true,
            dotData: FlDotData(show: false),
            preventCurveOverShooting: true,
            preventCurveOvershootingThreshold: 2,
            belowBarData: BarAreaData(
                show: true,
                color: SolarPanelResearchController.chartColors[index]),
          ));
        } else {
          lineBarsData.add(LineChartBarData(
            spots: [
              ..._solarPanelResearchController
                  .chartModelLast[index].chartFlSpotList,
            ],
            barWidth: 2,
            color: SolarPanelResearchController.chartLinesColors[index],
            curveSmoothness: 0.1,
            isCurved: true,
            dotData: FlDotData(show: false),
            preventCurveOverShooting: true,
            preventCurveOvershootingThreshold: 2,
            belowBarData: BarAreaData(
                show: true,
                color: SolarPanelResearchController.chartColors[index]),
          ));
        }
      }
    });

    return lineBarsData;
  }
}
