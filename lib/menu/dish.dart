import 'package:flutter/foundation.dart';
import 'package:messapp/menu/menu_repository.dart';
import 'package:meta/meta.dart';

enum Rating { Positive, NotRated, Negative }

class Dish with ChangeNotifier {
  Dish({
    @required this.id,
    @required this.name,
    @required this.mealId,
    Rating rating = Rating.NotRated,
    @required MenuRepository repository,
  })  : this._rating = rating,
        this._repo = repository;

  final int id;
  final String name;
  final int mealId;
  final MenuRepository _repo;
  Rating _rating;

  Rating get rating => _rating;

  Future<void> rate(Rating rating) async {
    _rating = rating;
    notifyListeners();
    await _repo.rate(dishId: id, mealId: mealId, rating: rating);
  }
}
