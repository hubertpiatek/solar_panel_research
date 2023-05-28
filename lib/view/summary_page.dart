import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/common/info_dialog.dart';
import 'package:solar_panel_research/consumer/solar_consumer.dart';
import '../controller/solar_panel_research_controller.dart';
import 'weather_view.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  late SolarPanelResearchController _solarPanelResearchController;

  @override
  void initState() {
    _solarPanelResearchController =
        context.read<SolarPanelResearchController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_solarPanelResearchController.isAfterInit) {
        _solarPanelResearchController.setIsAfterInit = true;
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        await _solarPanelResearchController.getSummaryDataFromPanel(
            context, mounted);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SolarConsumer<SolarPanelResearchController>(
      listen: true,
      builder: (context, model) {
        _solarPanelResearchController = model;
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.topCenter,
              image: AssetImage(
                "assets/solar_panel_background.png",
              ),
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              await _solarPanelResearchController.getSummaryDataFromPanel(
                  context, mounted);
            },
            child: ListView(
              children: [
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const WeatherView(),
                            _solarPanelResearchController.weather == null
                                ? Container()
                                : Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 16, 6),
                                    child: GestureDetector(
                                      child: IconButton(
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return const InfoDialog(
                                                  titleContent: "Informacja!",
                                                  infoContent:
                                                      "Prezentowane dane bazują na badaniach polikrystalicznego panelu fotowoltaicznego o mocy 110W. W celu osiągnięcia optymalnych statystyk i wyników, uwzględniane są tylko odczyty uzyskane w godzinach 07:00 - 21:00.");
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.info,
                                          color: Colors.white,
                                          size: 45,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(
                          height: 32.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            showSummaryStat(
                                "Wytworzona moc",
                                Colors.green.shade700,
                                Icons.solar_power_outlined,
                                "${_solarPanelResearchController.summaryModelFinal.generatedPower} kWh"),
                            showSummaryStat(
                                "Średnie napięcie",
                                Colors.yellow.shade700,
                                Icons.power_outlined,
                                "${_solarPanelResearchController.summaryModelFinal.averageVoltage} V"),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            showSummaryStat(
                                "Średnie natężenie",
                                Colors.red.shade700,
                                Icons.electric_meter_outlined,
                                "${_solarPanelResearchController.summaryModelFinal.averageCurrent} A"),
                            showSummaryStat(
                                "Średnia temp.",
                                Colors.blue.shade700,
                                Icons.wb_sunny_outlined,
                                "${_solarPanelResearchController.summaryModelFinal.averageTemperature} °C"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget showSummaryStat(
      String statTitle, Color statColor, IconData statIcon, String statValue) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.47,
      child: Card(
        color: Colors.grey.shade50,
        shadowColor: statColor,
        elevation: 15,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
          child: Column(
            children: [
              Text(
                statTitle,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(
                height: 16,
              ),
              _solarPanelResearchController.isSummaryDataLoading
                  ? const SizedBox(
                      height: 125,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: statColor, width: 2)),
                          child: InkWell(
                            child: Icon(
                              statIcon,
                              size: 45,
                              color: statColor,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Text(
                          statValue,
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black54),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
