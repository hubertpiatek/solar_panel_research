import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/common/stats_dialog.dart';
import 'package:solar_panel_research/consumer/solar_consumer.dart';
import '../controller/solar_panel_research_controller.dart';
import 'chart_view.dart';

class HistoricSolarData extends StatefulWidget {
  const HistoricSolarData({super.key});

  @override
  State<HistoricSolarData> createState() => _HistoricSolarDataState();
}

class _HistoricSolarDataState extends State<HistoricSolarData> {
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
                                                "Dane Historyczne",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 21,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          const Divider(
                                            height: 3,
                                            thickness: 2,
                                          ),
                                          const SizedBox(
                                            height: 24,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                "Wybierz zakres danych",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 50),
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              alignment:
                                                  AlignmentDirectional.center,
                                              hint: Text(
                                                _solarPanelResearchController
                                                    .actualSelectedHistoricPeriodFilter,
                                                textAlign: TextAlign.center,
                                              ),
                                              items:
                                                  SolarPanelResearchController
                                                      .historicFilters.values
                                                      .map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (value) async {
                                                await _solarPanelResearchController
                                                    .changeHistoricChartPeriod(
                                                        value ?? "");
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              getSingleHistoricAction(
                                                  "Okres", Icons.calendar_month,
                                                  () async {
                                                await _selectDatePeriod(
                                                    context);
                                              }),
                                              getSingleHistoricAction(
                                                  "Wybierz dzień", Icons.today,
                                                  () async {
                                                await _selectDateSingleDay(
                                                    context);
                                              }),
                                              getSingleHistoricAction(
                                                  "Statystyki", Icons.bar_chart,
                                                  () async {
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return StatsDialog(
                                                        errorContent:
                                                            "asd".toString());
                                                  },
                                                );
                                              }),
                                            ],
                                          ),
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
                            : const ChartView(isHistoricView: true),
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

  Future<void> _selectDatePeriod(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: child,
        );
      },
    );

    if (pickedDate != null) {
      _solarPanelResearchController.chartModelHistoric.isPeriod = true;
      await _solarPanelResearchController
          .getHistoricDataCalendarFilter(pickedDate);
    }
  }

  Future<void> _selectDateSingleDay(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 360)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: child,
        );
      },
    );
    if (pickedDate != null) {
      _solarPanelResearchController.chartModelHistoric.isPeriod = false;
      await _solarPanelResearchController
          .getHistoricDataCalendarFilter(pickedDate);
    }
  }

  Widget getSingleHistoricAction(
      String title, IconData iconData, Function clickAction) {
    return Card(
      elevation: 5,
      child: InkWell(
        splashColor: Colors.grey.shade800.withOpacity(0.4),
        onTap: () async {
          return await clickAction();
        },
        child: Ink(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    size: 50,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    width: 75,
                    child: Divider(
                      color: Colors.blue,
                      thickness: 1,
                      height: 10,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black54),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
