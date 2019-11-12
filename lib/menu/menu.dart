import 'package:flutter/foundation.dart';
import 'package:messapp/menu/meal.dart';
import 'package:messapp/util/date.dart';

class Menu {
  const Menu({
    @required this.date,
    @required this.meals,
  });

  final Date date;
  final List<Meal> meals;
}
