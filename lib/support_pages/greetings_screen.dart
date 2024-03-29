import 'package:flutter/material.dart';
import 'package:qc_parts_check/support_pages/about_screen.dart';
import 'package:qc_parts_check/support_pages/login_screen.dart';
import 'package:qc_parts_check/utils/exit_popup.dart';

class GreetingsScreen extends StatefulWidget {
  const GreetingsScreen({super.key});

  @override
  State<GreetingsScreen> createState() => _GreetingsScreenState();
}

class _GreetingsScreenState extends State<GreetingsScreen> with TickerProviderStateMixin {
  bool didPop = true;

  // Animation function
  late final AnimationController _controller = AnimationController(
    duration: const Duration(
      seconds: 2,
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        showExitPopup(context);
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "QC Parts Check",
          ),
          flexibleSpace: Material(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(0.8, 1),
                  colors: <Color>[
                    Color(0x28e3caca),
                    Color(0x2ad8de32),
                    Color(0x49ead66e),
                  ],
                  // Gradient from https://learnui.design/tools/gradient-generator.html
                  tileMode: TileMode.mirror,
                ),
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.info_outline_rounded,
              ),
              tooltip: "Tentang Aplikasi",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Material(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(0.8, 1),
                  colors: <Color>[
                    Color(0x28e3caca),
                    Color(0x2ad8de32),
                    Color(0x49ead66e),
                    Color(0x35f3cd0a),
                    Color(0xfff3f19e),
                    Color(0x76ecba17),
                    Color(0x8cf39060),
                    Color(0xa3fae927),
                  ],
                  // Gradient from https://learnui.design/tools/gradient-generator.html
                  tileMode: TileMode.mirror,
                ),
              ),
              child: ListView(
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
                          "assets/images/img-greetingsscreen.png",
                          width: 500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Center(
                      child: Text(
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
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Center(
                      child: Text(
                        "Aplikasi Pengecekan dan Pengarsipan Data Part Sepeda Motor Listrik GESITS di Incoming Area",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(40),
                        backgroundColor: Colors.yellowAccent, // <-- Button color
                        foregroundColor: Colors.blue, // <-- Splash color
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.play_arrow,
                            size: 40,
                          ),
                          Text(
                            "Mulai",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
