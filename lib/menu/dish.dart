import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

enum Rating { Positive, NotRated, Negative }

class Dish with ChangeNotifier {
  Dish({
    @required this.id,
    @required this.name,
    @required this.mealId,
    Rating rating = Rating.NotRated,
  }) : this._rating = rating;

  final int id;
  final String name;
  final int mealId;
  Rating _rating;

  Rating get rating => _rating;
}
