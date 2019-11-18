import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:messapp/util/app_colors.dart';

final appThemeData = ThemeData(
  appBarTheme: AppBarTheme(color: AppColors.appBarBackground, elevation: 0.0),
  fontFamily: 'Quicksand',
  textTheme: TextTheme(
    title: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
  ),
);
