import 'package:flutter/widgets.dart';

class Responsive {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double width(double percentage, BuildContext context) {
    return screenWidth(context) * (percentage / 100);
  }

  static double height(double percentage, BuildContext context) {
    return screenHeight(context) * (percentage / 100);
  }

  static double textSize(double baseSize, BuildContext context) {
    double scale = screenWidth(context) / 400;
    return baseSize * scale.clamp(0.8, 1.5);
  }

  static bool isSmallScreen(BuildContext context) => screenWidth(context) < 350;
  static bool isMediumScreen(BuildContext context) =>
      screenWidth(context) >= 350 && screenWidth(context) < 700;
  static bool isLargeScreen(BuildContext context) =>
      screenWidth(context) >= 700;
}
