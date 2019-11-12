import 'package:messapp/menu/dish.dart';
import 'package:meta/meta.dart';

class Meal {
  const Meal({
    @required this.id,
    @required this.name,
    @required this.dishes,
  });

  final int id;
  final String name;
  final List<Dish> dishes;
}
