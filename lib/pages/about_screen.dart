import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          "Tentang Aplikasi",
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
                height: 40,
              ),
              Stack(
                children: [
                  Center(
                    child: Image.asset(
                      "assets/images/as.gif",
                      height: 400,
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "About Application",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amarante(
                              fontSize: 35,
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "GESITS Electric Motorcycle Parts Checking Application for Quality Control",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amiri(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Hero(
                                tag: "gesits-logo",
                                child: Image.asset(
                                  "assets/images/gesits-logo.png",
                                  width: 200,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Hero(
                                tag: "wima-logo",
                                child: Image.asset(
                                  "assets/images/wima-logo.png",
                                  width: 200,
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
            ],
          ),
        ),
      ),
    );
  }
}
