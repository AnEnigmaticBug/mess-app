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
        CREATE TABLE Grub(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          organizer TEXT NOT NULL,
          date TEXT NOT NULL,
          signUpDeadline TEXT NOT NULL,
          cancelDeadline TEXT NOT NULL,
          slotATime TEXT,
          slotBTime TEXT,
          audience INTEGER NOT NULL CHECK(audience IN (0, 1, 2))
        )
      ''');

      await txn.execute('''
        CREATE TABLE Offering(
          id INTEGER PRIMARY KEY,
          grubId INTEGER NOT NULL,
          name TEXT NOT NULL,
          items TEXT NOT NULL,
          venue TEXT,
          price TEXT NOT NULL,
          FOREIGN KEY(grubId) REFERENCES Grub(id) ON DELETE CASCADE
        )
      ''');

      await txn.execute('''
        CREATE TABLE Ticket(
          id INTEGER PRIMARY KEY,
          offeringId INTEGER NOT NULL,
          slot INTEGER NOT NULL CHECK(slot IN (0, 1)),
          FOREIGN KEY(offeringId) REFERENCES Offering(id) ON DELETE CASCADE
        )
      ''');

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
        CREATE TABLE Notices(
          id INTEGER PRIMARY KEY,
          body TEXT,
          heading TEXT NOT NULL,
          startDate TEXT NOT NULL,
          endDate TEXT, 
          noticeType TEXT
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

      await txn.execute('''
        CREATE TABLE Contact(
          name TEXT NOT NULL,
          post TEXT NOT NULL,
          photoUrl TEXT NOT NULL,
          mobileNo TEXT NOT NULL,
          PRIMARY KEY(name, post) 
        )
      ''');
    });
  });

  return _db;
}
