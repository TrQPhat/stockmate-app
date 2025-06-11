import 'package:flutter/material.dart';

class AppColors {
  static const Color orange = Color(0xFFFF9800);
  static const Color deepOrange = Color(0xFFFF5722);
  static const Color red = Color(0xFFF44336);
  static const Color yellow = Color(0xFFFFEB3B);
  static const Color amber = Color(0xFFFFC107);
  static const Color lightOrange = Color(0xFFFFE0B2);
  static const Color lightRed = Color(0xFFFFCDD2);
  static const Color lightYellow = Color(0xFFFFF9C4);
  static const Color textDark = Color(0xFF424242);
  static const Color textLight = Color(0xFF757575);
  static const Color white = Color(0xFFFFFFFF);
}

class AppGradients {
  static const LinearGradient orangeRed = LinearGradient(
    colors: [AppColors.orange, AppColors.deepOrange, AppColors.red],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient orangeYellow = LinearGradient(
    colors: [AppColors.orange, AppColors.amber, AppColors.yellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFFFFF8E1),
      Color(0xFFFFF3E0),
      Color(0xFFFFEBEE),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
