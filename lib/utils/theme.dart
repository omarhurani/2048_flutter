import 'package:flutter/material.dart';
import 'package:game_2048/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

BorderRadius get borderRadius => const BorderRadius.all(Radius.circular(10));

final theme = ThemeData(
  primarySwatch: Colors.brown,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: scaffoldBackgroundColor,
  backgroundColor: backgroundColor,
  accentColor: accentColor,
  fontFamily: GoogleFonts.robotoSlab().fontFamily,
  textTheme: TextTheme().apply(
    displayColor: primaryColor,
    bodyColor: accentColor,
  ).copyWith(
    headline1: GoogleFonts.robotoSlab().copyWith(
      fontWeight: FontWeight.w900
    ),
    headline6: GoogleFonts.robotoSlab().copyWith(
      fontWeight: FontWeight.w600,
      color: primaryColor,
    ),
    bodyText1: GoogleFonts.robotoSlab().copyWith(
      color: bodyText1Color
    ),
  ),

  iconTheme: IconThemeData(
    color: primaryColor
  ),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states){
        if(states.contains(MaterialState.disabled))
          return backgroundColor;
        return primaryColor;
      }),
      foregroundColor: MaterialStateProperty.all<Color>(scaffoldBackgroundColor),
      padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(vertical: 15, horizontal: 25)
      )
    )
  ),
  inputDecorationTheme: InputDecorationTheme(
    // contentPadding: EdgeInsets.all(0),
    isDense: true,
    border: OutlineInputBorder(
      borderRadius: borderRadius,
    ),
    errorStyle: TextStyle(
      fontSize: 0.001,
    )

  )
);