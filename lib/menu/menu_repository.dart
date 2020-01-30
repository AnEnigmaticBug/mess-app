import 'dart:convert';
import 'package:messapp/menu/dish.dart';
import 'package:messapp/menu/meal.dart';
import 'package:messapp/menu/menu.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:messapp/util/simple_repository.dart';
import 'package:messapp/util/time_keeper.dart';
import 'package:meta/meta.dart';
import 'package:nice/nice.dart';
import 'package:sqflite/sqflite.dart';

class MenuRepository extends SimpleRepository {
  MenuRepository({
    @required Database database,
    @required NiceClient client,
    @required TimeKeeper keeper,
  })  : this._db = database,
        this._client = client,
        this._keeper = keeper {
    keeper.isDue(PrefKeys.ratingsPush).then((isDue) async {
      if (isDue) {
        await _removeStaleRatings();
        await _pushRatings();
      }
    }).catchError((e) {});
  }

  Database _db;
  NiceClient _client;
  TimeKeeper _keeper;
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

  Future<void> _removeStaleRatings() async {
    await _db.rawDelete('''
      DELETE
        FROM DishRating
       WHERE mealId NOT IN (
         SELECT id
           FROM Meal
       )
    ''');
  }

  Future<void> _pushRatings() async {
    final rows = await _db.rawQuery('''
      SELECT dishId, mealId, rating
        FROM DishRating
    ''');

    final reqBody = json.encode(rows
        .map((r) => {
              'item_id': r['dishId'],
              'menu_id': r['mealId'],
              'rating': r['rating'] == 0 ? 'U' : r['rating'] == 1 ? 'N' : 'D',
            })
        .toList());

    final res = await _client.post('/mess/menu/', body: reqBody);

    if (res.statusCode != 200) {
      throw res.toException();
    }

    await _keeper.reset(PrefKeys.ratingsPush);
  }
}
