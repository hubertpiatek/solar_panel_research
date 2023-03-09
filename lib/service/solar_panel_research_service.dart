import '../common/http_exception.dart';

class SolarPanelResearchService {
  Future<void> getSummaryData() async {
    //throw HttpException("DUPA");
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> getLastSolarData() async {
    //throw HttpException("DUPA");
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
