import 'package:messapp/menu/dish.dart';
import 'package:messapp/menu/menu.dart';
import 'package:meta/meta.dart';

class MenuRepository {
  Future<List<Menu>> get menus async {}

  Future<void> refresh() async {}

  Future<void> rate({
    @required int dishId,
    @required int mealId,
    @required Rating rating,
  }) async {}
}
