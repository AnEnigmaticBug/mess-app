import 'dart:convert';
import 'package:messapp/menu/dish.dart';
import 'package:messapp/menu/meal.dart';
import 'package:messapp/menu/menu.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:meta/meta.dart';
import 'package:nice/nice.dart';
import 'package:sqflite/sqflite.dart';

class MenuRepository {
  MenuRepository({
    @required Database database,
    @required NiceClient client,
  })  : this._db = database,
        this._client = client;

  Database _db;
  NiceClient _client;
  List<Menu> _cache = [];

  Future<List<Menu>> get menus async {
    if (_cache.isNotEmpty) {
      return _cache;
    }

    if (await _dbOutdated) {
      await _db.rawDelete('''
        DELETE
          FROM DishRating
      ''');

      await refresh();
    }

    await _populateCache();
    return _cache;
  }

  Future<void> refresh() async {
    final res = await _client.get('/mess/menu/');

    if (res.statusCode != 200) {
      throw res.toException();
    }

    final mealsJson = json.decode(res.body) as List<dynamic>;

    await _db.transaction((txn) async {
      await txn.rawDelete('''
        DELETE
          FROM Meal
      ''');

      await txn.rawDelete('''
        DELETE
          FROM Dish
      ''');

      await txn.rawDelete('''
        DELETE
          FROM DishToMeal
      ''');

      for (var mealJson in mealsJson) {
        await txn.rawInsert('''
          INSERT
            INTO Meal (id, name, date, orderValue)
          VALUES (?, ?, ?, ?)
        ''', [mealJson['id'], mealJson['category'], mealJson['date'], 1]);

        for (var dishJson in mealJson['items']) {
          await txn.rawInsert('''
            INSERT OR IGNORE
              INTO Dish (id, name)
            VALUES (?, ?)
          ''', [dishJson['id'], dishJson['name']]);

          await txn.rawInsert('''
            INSERT
              INTO DishToMeal (dishId, mealId)
            VALUES (?, ?)
          ''', [dishJson['id'], mealJson['id']]);
        }
      }
    });

    await _populateCache();
  }

  Future<void> rate({
    @required int dishId,
    @required int mealId,
    @required Rating rating,
  }) async {
    await _db.transaction((txn) async {
      final rows = await txn.rawQuery('''
        SELECT date
          FROM Meal
         WHERE id = ?
      ''', [mealId]);

      final date = Date.parse(rows.first['date']);

      if (date.compareTo(Date.now()) == 1) {
        throw Exception('You can\'t rate items in advance');
      }

      await txn.rawUpdate('''
        INSERT OR REPLACE
          INTO DishRating (dishId, mealId, rating)
        VALUES (?, ?, ?)
      ''', [dishId, mealId, rating.index]);
    });
  }

  Future<bool> get _dbOutdated async {
    final res = await _db.rawQuery('''
      SELECT COUNT(*) AS c
        FROM Meal
       WHERE date = ?
    ''', [Date.now().toIso8601String()]);

    return res.first['c'] == 0;
  }

  Future<List<Map<String, dynamic>>> get _dbRows async {
    return await _db.rawQuery('''
      SELECT m.id AS mealId, m.name AS mealName, m.date AS mealDate, d.id AS dishId, d.name AS dishName, COALESCE(dr.rating, ${Rating.NotRated.index}) AS rating
        FROM Meal m
             INNER JOIN DishToMeal dm ON dm.mealId == m.id
             INNER JOIN Dish d ON d.id == dm.dishId
             LEFT  JOIN DishRating dr ON dr.dishId == dm.dishId AND dr.mealId == dm.mealId
       ORDER BY m.date, m.orderValue
    ''');
  }

  Future<void> _populateCache() async {
    final menus = _cache;
    menus.clear();

    for (var row in await _dbRows) {
      if (menus.isEmpty ||
          menus.last.date.toIso8601String() != row['mealDate']) {
        menus.add(Menu(
          date: Date.parse(row['mealDate']),
          meals: [],
        ));
      }

      final meals = menus.last.meals;
      if (meals.isEmpty || meals.last.name != row['mealName']) {
        meals.add(Meal(
          id: row['mealId'],
          name: row['mealName'],
          dishes: [],
        ));
      }

      meals.last.dishes.add(Dish(
        id: row['dishId'],
        name: row['dishName'],
        mealId: row['mealId'],
        rating: Rating.values[row['rating']],
        repository: this,
      ));
    }
  }
}
