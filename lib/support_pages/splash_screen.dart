import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qc_parts_check/support_pages/greetings_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  startSplashScreen() async {
    var duration = const Duration(
      seconds: 3,
    );

    return Timer(
      duration,
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GreetingsScreen(),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  // Animation function
  late final AnimationController _controller = AnimationController(
    duration: const Duration(
      seconds: 1,
    ),
    vsync: this,
  )..forward();

  // Animation settings
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color(0xadeacd3a),
                Color(0xc8d7de3a),
                Color(0xc8e8cd41),
                Color(0xd3bce525),
                Color(0xffdcd95f),
                Color(0x76f1c32f),
                Color(0x9097a925),
                Color(0xe580f123),
              ],
              // Gradient from https://learnui.design/tools/gradient-generator.html
              tileMode: TileMode.mirror,
            ),
          ),
          child: ListView(
            children: [
              const SizedBox(
                height: 100,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Hero(
                          tag: "wima-logo",
                          child: Image.asset(
                            "assets/images/wima-logo.png",
                            width: 150,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Hero(
                          tag: "gesits-logo",
                          child: Image.asset(
                            "assets/images/gesits-logo.png",
                            width: 150,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: ScaleTransition(
                      scale: _animation,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          "assets/images/img-splashscreen.png",
                          width: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "QC Parts Check",
                    style: TextStyle(
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 2,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
