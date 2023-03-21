import 'package:flutter/material.dart';
import 'package:solar_panel_research/view/summary_page.dart';
import 'historic_solar_data.dart';
import 'last_solar_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(58, 133, 255, 1),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Colors.black12.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        child: TabBar(
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 3.0, color: Colors.blue),
          ),
          controller: _tabController,
          labelColor: Colors.white,
          tabs: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: const Tab(
                child: Text(
                  "Start",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: const Tab(
                child: Text(
                  "Dane Aktualne",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: const Tab(
                child: Text(
                  "Dane Historyczne",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text("Badania Panelu Fotowoltaicznego"),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SummaryPage(),
          LastSolarData(),
          HistoricSolarData(),
        ],
      ),
    );
  }
}
