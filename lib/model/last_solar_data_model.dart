class LastSolarDataModel {
  DateTime solarDate;
  double power;
  double voltage;
  double amper;
  double temperature;
  double humidity;
  double lightIntensity;
  String direction;
  int solarAngle;

  LastSolarDataModel({
    required this.solarDate,
    required this.power,
    required this.voltage,
    required this.amper,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    required this.direction,
    required this.solarAngle,
  });

  factory LastSolarDataModel.fromJson(Map<String, dynamic> json) {
    return LastSolarDataModel(
      solarDate: json['solarDate'],
      power: json['power'],
      voltage: json['voltage'],
      amper: json['amper'],
      temperature: json['temperature'],
      humidity: json['humidity'],
      lightIntensity: json['lightIntensity'],
      direction: json['direction'],
      solarAngle: json['solarAngle'],
    );
  }
}
