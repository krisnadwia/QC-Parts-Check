import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qc_parts_check/pages/splash_screen.dart';
import 'package:qc_parts_check/utils/custom_scroll.dart';
import 'package:qc_parts_check/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: CustomScroll(),
      title: "QC Parts Check",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
