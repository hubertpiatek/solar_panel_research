class SummaryModel {
  double generatedPower;
  double averageVoltage;
  double averageAmper;
  double averageTemperature;

  SummaryModel(
      {required this.generatedPower,
      required this.averageVoltage,
      required this.averageAmper,
      required this.averageTemperature});

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      generatedPower: json['generatedPower'],
      averageVoltage: json['generatedPower'],
      averageAmper: json['generatedPower'],
      averageTemperature: json['generatedPower'],
    );
  }
}
