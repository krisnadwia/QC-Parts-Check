import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qc_parts_check/support_pages/grafik/sub_pages/raya_graph_pages/detail_pages/raya_electric_graph_screen.dart';
import 'package:qc_parts_check/support_pages/grafik/sub_pages/raya_graph_pages/detail_pages/raya_general_graph_screen.dart';
import 'package:qc_parts_check/support_pages/grafik/sub_pages/raya_graph_pages/detail_pages/raya_metal_graph_screen.dart';
import 'package:qc_parts_check/support_pages/grafik/sub_pages/raya_graph_pages/detail_pages/raya_plastic_graph_screen.dart';

class RayaGraphHomeScreen extends StatefulWidget {
  const RayaGraphHomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RayaGraphHomeScreenState();
}

class _RayaGraphHomeScreenState extends State<RayaGraphHomeScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    // Retrieve logged in user data
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {});
    });
  }

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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          tooltip: "Kembali",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xa3e8d820),
        title: const Text(
          "Grafik Raya",
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
              Center(
                child: ScaleTransition(
                  scale: _animation,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Hero(
                      tag: "raya-samping",
                      child: Image.asset(
                        "assets/images/raya-samping.png",
                        width: 260,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Material(
                          color: const Color(0xb3a18b3b),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RayaMetalGraphScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Hero(
                                    tag: "img-metal-part",
                                    child: Image.asset(
                                      "assets/images/img-metal-part.png",
                                      width: 100,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Metal Parts",
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Material(
                          color: const Color(0xffc2ad29),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RayaPlasticGraphScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Hero(
                                    tag: "img-plastic-part",
                                    child: Image.asset(
                                      "assets/images/img-plastic-part.png",
                                      width: 80,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Plastic Parts",
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Material(
                          color: const Color(0xffcebd54),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RayaGeneralGraphScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Hero(
                                    tag: "img-general-part",
                                    child: Image.asset(
                                      "assets/images/img-general-part.png",
                                      width: 100,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "General Parts",
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Material(
                          color: const Color(0xffbad347),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RayaElectricGraphScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Hero(
                                    tag: "img-electric-part",
                                    child: Image.asset(
                                      "assets/images/img-electric-part.png",
                                      width: 100,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Electric Parts",
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
