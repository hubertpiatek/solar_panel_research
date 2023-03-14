import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/consumer/solar_consumer.dart';
import 'package:solar_panel_research/controller/solar_panel_research_controller.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
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
          return _solarPanelResearchController.weather == null
              ? Container()
              : Container(
                  margin: const EdgeInsets.all(6.0),
                  width: MediaQuery.of(context).size.width * 0.57,
                  child: Card(
                    color: Colors.grey.shade50.withOpacity(0.8),
                    elevation: 15,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _solarPanelResearchController.weather?.areaName ??
                                "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 17.5, color: Colors.black54),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                "https://openweathermap.org/img/wn/${_solarPanelResearchController.weather?.weatherIcon}@2x.png",
                                width: 75,
                                height: 75,
                              ),
                              Text(
                                "${_solarPanelResearchController.weather?.temperature?.celsius?.toStringAsFixed(1)} °C",
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black54),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                            ],
                          ),
                          Text(
                            "${_solarPanelResearchController.weather?.weatherDescription![0].toUpperCase()}${_solarPanelResearchController.weather?.weatherDescription?.substring(1)}",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15.5,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Ciśnienie: ${_solarPanelResearchController.weather?.pressure?.toStringAsFixed(0)} hPa",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15.5,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        });
  }
}
