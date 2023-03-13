class SolarDataModel {
  DateTime solarDate;
  double power;
  double voltage;
  double current;
  double temperature;
  int humidity;
  double lightIntensity;
  String direction;
  int solarAngle;

  SolarDataModel({
    required this.solarDate,
    required this.power,
    required this.voltage,
    required this.current,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    required this.direction,
    required this.solarAngle,
  });

  factory SolarDataModel.fromJson(Map<String, dynamic> json, DateTime date) {
    double voltage = double.tryParse(json['voltage'] ?? "") ?? 0.0;
    double current = double.tryParse(json['current'] ?? "") ?? 0.0;
    double basicPower = voltage * current;
    double power = double.tryParse(basicPower.toStringAsFixed(2)) ?? 0.0;
    return SolarDataModel(
      solarDate: date,
      power: power,
      voltage: voltage,
      current: current,
      temperature: double.tryParse(json['temperature'] ?? "") ?? 0.0,
      humidity: (double.tryParse(
                  (double.tryParse(json['humidity'] ?? "") ?? 0.0)
                      .toStringAsFixed(0)) ??
              0.0)
          .toInt(),
      lightIntensity: double.tryParse(json['light_intensity'] ?? "") ?? 0.0,
      direction: json['direction'] ?? "",
      solarAngle: int.tryParse(json['tilt_angle'] ?? "") ?? 0,
    );
  }
}
