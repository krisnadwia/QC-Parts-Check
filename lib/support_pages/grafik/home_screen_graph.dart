import 'package:flutter/material.dart';
import 'package:qc_parts_check/support_pages/grafik/sub_pages/g1_graph_pages/g1_graph_home_screen.dart';
import 'package:qc_parts_check/support_pages/grafik/sub_pages/raya_graph_pages/raya_graph_home_screen.dart';

class HomeScreenGraph extends StatefulWidget {
  const HomeScreenGraph({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenGraphState();
}

class _HomeScreenGraphState extends State<HomeScreenGraph>
    with TickerProviderStateMixin {
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xa3e8d820),
        title: const Text(
          "Grafik",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Material(
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
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        "assets/images/line-bars.gif",
                        width: 100,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            left: 60,
                            right: 60,
                            bottom: 20,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Material(
                            color: const Color(0xa69fe512),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const G1GraphHomeScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Center(
                                      child: ScaleTransition(
                                        scale: _animation,
                                        child: Hero(
                                          tag: "g1-samping",
                                          child: Image.asset(
                                            "assets/images/g1-samping.png",
                                            width: 140,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Hero(
                                      tag: "gesits-logo-g1",
                                      child: Image.asset(
                                        "assets/images/gesits-logo.png",
                                        width: 80,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "G1",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 60,
                            right: 60,
                            bottom: 20,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Material(
                            color: const Color(0xa6a5b007),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RayaGraphHomeScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Center(
                                      child: ScaleTransition(
                                        scale: _animation,
                                        child: Hero(
                                          tag: "raya-samping",
                                          child: Image.asset(
                                            "assets/images/raya-samping.png",
                                            width: 260,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Hero(
                                      tag: "gesits-logo-raya",
                                      child: Image.asset(
                                        "assets/images/gesits-logo.png",
                                        width: 80,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Raya",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
