import 'package:flutter/material.dart';

const Color backgroundColor = Color.fromARGB(255, 0, 0, 0);
const Color primaryColor = Color.fromARGB(255, 83, 38, 115);

ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: backgroundColor,
  colorScheme: const ColorScheme.light(
    primary: primaryColor,
  ),
  sliderTheme: SliderThemeData(
    trackHeight: 1,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 5),
  ),
);
