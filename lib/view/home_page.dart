import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/controller/solar_panel_research_controller.dart';
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
      endDrawer: Container(
        margin: const EdgeInsets.only(top: kToolbarHeight / 2),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            height: MediaQuery.of(context).size.width * 0.74,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(20.0))),
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Expanded(
                flex: 8,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        color: Colors.blue.shade700,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: const Text(
                                "Wybierz panele do badań",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ),
                            )),
                          ],
                        ),
                      ),
                      ...getPanelsList(),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20.0))),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
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
        title: const Text(
          "Badania Paneli Fotowoltaicznych",
          style: TextStyle(fontSize: 18),
        ),
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

  List<Widget> getPanelsList() {
    List<Widget> panelsList = [];
    SolarPanelResearchController.listOfPanels.forEach((index, description) {
      panelsList.add(Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Checkbox(
                      value: SolarPanelResearchController.enabledPanels[index],
                      onChanged: (value) {
                        if (!(value != null &&
                            !value &&
                            SolarPanelResearchController
                                    .getEnabledPanelsAmount() ==
                                1)) {
                          setState(() {
                            SolarPanelResearchController.enabledPanels[index] =
                                !SolarPanelResearchController
                                    .enabledPanels[index]!;
                          });
                          context
                              .read<SolarPanelResearchController>()
                              .reloadDataOnPanelAction(index);
                        }
                      }),
                ),
                Expanded(
                  flex: 9,
                  child: Text(
                    description,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 17, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.blue,
          )
        ],
      ));
    });

    return panelsList;
  }
}
