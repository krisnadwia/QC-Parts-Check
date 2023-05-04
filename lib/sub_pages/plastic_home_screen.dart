import 'package:flutter/material.dart';
import 'package:qc_parts_check/detail_pages/g1_plastic_screen.dart';
import 'package:qc_parts_check/detail_pages/raya_plastic_screen.dart';

class PlasticHomeScreen extends StatefulWidget {
  const PlasticHomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PlasticHomeScreenState();
}

class _PlasticHomeScreenState extends State<PlasticHomeScreen> with TickerProviderStateMixin {
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
          tooltip: "Kembali ke Home Screen",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xa3e8d820),
        title: const Text(
          "Plastic Parts",
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
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "Plastic Parts",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Hero(
                      tag: "img-plastic-part",
                      child: Image.asset(
                        "assets/images/img-plastic-part.png",
                        width: 80,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Material(
                      color: const Color(0xa69fe512),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const G1PlasticScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 12,
                              ),
                              Center(
                                child: ScaleTransition(
                                  scale: _animation,
                                  child: Image.asset(
                                    "assets/images/img-g1.png",
                                    width: 120,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Material(
                      color: const Color(0xa6a5b007),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RayaPlasticScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Center(
                                child: ScaleTransition(
                                  scale: _animation,
                                  child: Image.asset(
                                    "assets/images/img-raya.png",
                                    width: 120,
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
      ),
    );
  }
}
