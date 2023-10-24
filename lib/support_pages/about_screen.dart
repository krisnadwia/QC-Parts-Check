import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// URL function
_launchURL() async {
  const url = "mailto:krisnadwiandrianto04@gmail.com";
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw "Could not launch $url";
  }
}

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
          tooltip: "Kembali",
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
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text(
                        "About Application",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text(
                        "Application for Checking and Archiving GESITS Electric Motorcycle Part Data in the Incoming Area",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
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
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () {
                    _launchURL();
                  },
                  child: const Text(
                    "Berikan Feedback Kepada Developer",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
