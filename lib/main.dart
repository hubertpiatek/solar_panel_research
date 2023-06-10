import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:solar_panel_research/controller/solar_panel_research_controller.dart';
import 'package:solar_panel_research/view/home_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Future.delayed(const Duration(milliseconds: 500));
  FlutterNativeSplash.remove();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SolarPanelApp());
}

class SolarPanelApp extends StatelessWidget {
  const SolarPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SolarPanelResearchController()),
      ],
      child: MaterialApp(
          title: "Badania Paneli Fotowoltaicznych",
          localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
          supportedLocales: const [
            Locale('en', "EN"),
            Locale('pl', "PL"),
          ],
          theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: Colors.red,
              primaryColorDark: Colors.green),
          home: const HomePage()),
    );
  }
}
