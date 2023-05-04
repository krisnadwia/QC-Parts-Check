import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomScroll extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    // For mouse use on device (mobile, desktop, and web)
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
