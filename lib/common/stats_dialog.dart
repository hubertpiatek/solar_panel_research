import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/consumer/solar_consumer.dart';
import '../controller/solar_panel_research_controller.dart';

class StatsDialog extends StatefulWidget {
  final String errorContent;
  const StatsDialog({required this.errorContent, super.key});

  @override
  State<StatsDialog> createState() => _StatsDialogState();
}

class _StatsDialogState extends State<StatsDialog> {
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
        return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.68,
              width: MediaQuery.of(context).size.width * 0.8,
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(4.0),
                              child: const Text(
                                "Statystyki",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 22, color: Colors.black54),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(4.0),
                              child: Text(
                                _solarPanelResearchController
                                        .chartModelHistoric.isDateSingleDay
                                    ? DateFormat("dd.MM.yyyy").format(
                                        _solarPanelResearchController
                                            .chartModelHistoric.selectedDate)
                                    : "${DateFormat("dd.MM.yyyy").format(_solarPanelResearchController.chartModelHistoric.selectedDate)} - ${DateFormat("dd.MM.yyyy").format(DateTime.now())}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ...getLastInfoSingleData(
                        "Wytworzona moc",
                        "${_solarPanelResearchController.solarStatsModel.generatedPower} kWh",
                        Icons.solar_power_outlined,
                        Colors.green),
                    ...getLastInfoSingleData(
                        "Średnie napięcie",
                        "${_solarPanelResearchController.solarStatsModel.averageVoltage} V",
                        Icons.power_outlined,
                        Colors.yellow.shade800),
                    ...getLastInfoSingleData(
                        "Średnie natężenie",
                        "${_solarPanelResearchController.solarStatsModel.averageCurrent} A",
                        Icons.electric_meter_outlined,
                        Colors.red),
                    ...getLastInfoSingleData(
                        "Średnia temperatura",
                        "${_solarPanelResearchController.solarStatsModel.averageTemperature} °C",
                        Icons.sunny_snowing,
                        Colors.blue),
                    ...getLastInfoSingleData(
                        "Średnia wilgotność",
                        "${_solarPanelResearchController.solarStatsModel.averageHumidity} %",
                        Icons.water_outlined,
                        Colors.blue),
                    ...getLastInfoSingleData(
                        "Średnia intensywność światła",
                        "${_solarPanelResearchController.solarStatsModel.averageLightIntensity} lux",
                        Icons.lightbulb_outline,
                        Colors.yellow.shade700),
                    ...getLastInfoSingleData(
                        "Ostatni kierunek panelu:",
                        _solarPanelResearchController
                            .solarStatsModel.lastdirection,
                        Icons.north_east,
                        Colors.blue),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
    );
  }

  List<Widget> getLastInfoSingleData(
      String title, String content, IconData icon, Color color) {
    return [
      const SizedBox(
        height: 8,
      ),
      Container(
        margin: const EdgeInsets.fromLTRB(8.0, 2.0, 0.0, 2.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
      const SizedBox(
        height: 7,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 8,
          ),
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(
            width: 7,
          ),
          Text(
            content,
            style: const TextStyle(
                fontSize: 19,
                color: Colors.black54,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ];
  }
}
