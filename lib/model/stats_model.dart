class StatsModel {
  double generatedPower;
  double averageVoltage;
  double averageCurrent;
  double averageTemperature;
  int averageHumidity;
  double averageLightIntensity;
  String lastdirection;

  StatsModel({
    required this.generatedPower,
    required this.averageVoltage,
    required this.averageCurrent,
    required this.averageTemperature,
    required this.averageHumidity,
    required this.averageLightIntensity,
    required this.lastdirection,
  });
}
