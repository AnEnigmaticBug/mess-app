import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database _db;

Future<Database> databaseInstance(String dbName) async {
  if (_db != null) {
    return _db;
  }

  String path = join(await getDatabasesPath(), dbName);
  _db = await openDatabase(path, version: 1, onCreate: (db, _) async {
    await db.transaction((txn) async {
      await txn.execute('''PRAGMA foreign_keys = ON''');

      await txn.execute('''
        CREATE TABLE Dish(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL
        )
      ''');

      await txn.execute('''
        CREATE TABLE Meal(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          date TEXT NOT NULL,
          orderValue INTEGER NOT NULL
        )
      ''');

      await txn.execute('''
        CREATE TABLE DishToMeal(
          dishId INTEGER NOT NULL,
          mealId INTEGER NOT NULL,
          PRIMARY KEY(dishId, mealId),
          FOREIGN KEY(dishId) REFERENCES Dish(id) ON DELETE CASCADE,
          FOREIGN KEY(mealId) REFERENCES Meal(id) ON DELETE CASCADE
        )
      ''');

      await txn.execute('''
        CREATE TABLE DishRating(
          dishId INTEGER NOT NULL,
          mealId INTEGER NOT NULL,
          rating INTEGER NOT NULL CHECK(rating IN (0, 1, 2)),
          PRIMARY KEY(dishId, mealId)
        )
      ''');

      await txn.execute('''
        CREATE TABLE ActiveIssue(
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          dateCreated TEXT NOT NULL,
          upvoteCount INTEGER NOT NULL,
          upvoted INTEGER NOT NULL CHECK(upvoted IN (0, 1)),
          flagged INTEGER NOT NULL CHECK(flagged IN (0, 1))
        )
      ''');

      await txn.execute('''
        CREATE TABLE SolvedIssue(
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          dateCreated TEXT NOT NULL,
          upvoteCount INTEGER NOT NULL,
          upvoted INTEGER NOT NULL CHECK(upvoted IN (0, 1)),
          flagged INTEGER NOT NULL CHECK(upvoted IN (0, 1)),
          dateSolved TEXT NOT NULL,
          reason TEXT NOT NULL
        )
      ''');
      });
  });

  return _db;
}
