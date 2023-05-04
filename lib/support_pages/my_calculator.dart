import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class MyCalculator extends StatefulWidget {
  const MyCalculator({super.key});

  @override
  State<StatefulWidget> createState() => _MyCalculatorState();
}

class _MyCalculatorState extends State<MyCalculator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: "Kembali ke Halaman Sebelumnya",
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xa3e8d820),
        title: const Text(
          "My Calculator",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      body: const SimpleCalculator(
        theme: CalculatorThemeData(
          displayColor: Colors.black,
          displayStyle: TextStyle(
            fontSize: 80,
            color: Colors.yellow,
          ),
          /*...*/
        ),
      ),
    );
  }
}
