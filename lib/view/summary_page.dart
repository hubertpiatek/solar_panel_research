import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/consumer/solar_consumer.dart';

import '../common/error_alert_dialog.dart';
import '../common/http_exception.dart';
import '../controller/solar_panel_research_controller.dart';

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
      await getSummaryData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SolarConsumer<SolarPanelResearchController>(
      listen: true,
      builder: (context, model) {
        _solarPanelResearchController = model;
        return SingleChildScrollView(
          //physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: RefreshIndicator(
              onRefresh: () async {
                await getSummaryData();
              },
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/solar_panel_background.png",
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          showSummaryStat(
                              "Wytworzona moc",
                              Colors.green.shade700,
                              Icons.solar_power_outlined,
                              "325,65 Wh"),
                          showSummaryStat(
                              "Średnie napięcie",
                              Colors.yellow.shade700,
                              Icons.power_outlined,
                              "15,23 V"),
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
                              "2,15 A"),
                          showSummaryStat("Średnia temp.", Colors.blue.shade700,
                              Icons.wb_sunny_outlined, "14,45 °C"),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.26,
                      child: ListView()),
                ],
              ),
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

  Future<void> getSummaryData() async {
    try {
      await _solarPanelResearchController.getSummaryData();
    } catch (error) {
      await showDialog(
        context: context,
        builder: (context) {
          return ErrorAlertDialog(errorContent: error.toString());
        },
      );
      _solarPanelResearchController.setIsSummaryDataLoading = false;
    }
  }
}
