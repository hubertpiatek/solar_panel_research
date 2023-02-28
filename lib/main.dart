import 'package:flutter/material.dart';
import 'package:solar_panel_research/controller/home_page_controller.dart';
import 'package:solar_panel_research/view/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const SolarPanelApp());
}

class SolarPanelApp extends StatelessWidget {
  const SolarPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomePageController()),
      ],
      child: MaterialApp(
          title: 'Solar Panel Research',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: Colors.red,
              primaryColorDark: Colors.green),
          home: const HomePage()),
    );
  }
}
