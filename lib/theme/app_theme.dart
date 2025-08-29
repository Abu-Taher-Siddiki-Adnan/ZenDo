import 'package:flutter/material.dart';

class AppTheme {
  // Cyan color palette
  static const Color primaryCyan = Color(0xFF00BCD4);
  static const Color lightCyan = Color(0xFF62EBFF);
  static const Color darkCyan = Color(0xFF008BA3);
  static const Color accentTeal = Color(0xFF0097A7);
  static const Color lightBackground = Color(0xFFF5FDFF);
  static const Color darkBackground = Color(0xFF121F22);
  static const Color textColorLight = Color(0xFF263238);
  static const Color textColorDark = Color(0xFFECEFF1);

  // Beautiful cyan gradient
  static BoxDecoration get gradientBoxDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightCyan, primaryCyan, darkCyan],
        stops: const [0.1, 0.5, 0.9],
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: primaryCyan,
      colorScheme: const ColorScheme.light().copyWith(
        primary: primaryCyan,
        secondary: accentTeal,
        background: lightBackground,
        onBackground: textColorLight,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryCyan,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryCyan,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      cardTheme: ThemeData.light().cardTheme.copyWith(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryCyan,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryCyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentTeal, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: textColorLight),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textColorLight),
        bodyMedium: TextStyle(color: textColorLight),
        titleMedium: TextStyle(color: textColorLight, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textColorLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryCyan,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: primaryCyan,
        secondary: lightCyan,
        background: darkBackground,
        onBackground: textColorDark,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCyan,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: ThemeData.dark().cardTheme.copyWith(
        elevation: 3,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFF1E2A2D),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryCyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightCyan, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF1E2A2D),
        labelStyle: const TextStyle(color: textColorDark),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textColorDark),
        bodyMedium: TextStyle(color: textColorDark),
        titleMedium: TextStyle(color: textColorDark, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textColorDark),
      ),
    );
  }

  static TextStyle get welcomeTextStyle {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
  }

  static TextStyle get taskTitleStyle {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textColorLight,
    );
  }

  static TextStyle get taskDescriptionStyle {
    return const TextStyle(
      fontSize: 14,
      color: Color(0xFF546E7A),
    );
  }

  static BoxDecoration get cardGradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightCyan.withOpacity(0.8), primaryCyan.withOpacity(0.8)],
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: primaryCyan.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration get buttonGradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightCyan, primaryCyan],
      ),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: primaryCyan.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}