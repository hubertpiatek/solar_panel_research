import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_panel_research/consumer/solar_consumer.dart';
import 'package:solar_panel_research/controller/home_page_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageController _homePageController;

  @override
  void initState() {
    _homePageController = context.read<HomePageController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SolarConsumer<HomePageController>(
      builder: (context, model) {
        _homePageController = model;
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text("ok")),
        );
      },
    );
  }
}
