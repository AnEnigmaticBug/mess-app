import 'dart:convert';

import 'package:messapp/contacts/contact.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:messapp/util/simple_repository.dart';
import 'package:messapp/util/time_keeper.dart';
import 'package:meta/meta.dart';
import 'package:nice/nice.dart';
import 'package:sqflite/sqlite_api.dart';

class ContactRepository extends SimpleRepository {
  ContactRepository({
    @required Database database,
    @required NiceClient client,
    @required TimeKeeper keeper,
  })  : this._db = database,
        this._client = client,
        this._keeper = keeper;

  final Database _db;
  final NiceClient _client;
  final TimeKeeper _keeper;
  List<Contact> _cache = [];

  Future<List<Contact>> get contacts async {
    if (_cache.isEmpty) {
      await _populateCache();
    }

    if (_cache.isEmpty || await _keeper.isDue(PrefKeys.contactsRefresh)) {
      await refresh();
    }

    return _cache;
  }

  Future<void> refresh() async {
    final res = await _client.get('/contacts');

    if (res.statusCode != 200) {
      throw res.toException();
    }

    final contactsJson = json.decode(res.body);

    await _db.transaction((txn) async {
      await txn.rawDelete('''
        DELETE
          FROM Contact
      ''');

      for (var contactJson in contactsJson) {
        await txn.rawInsert('''
          INSERT
            INTO Contact (name, post, photoUrl, mobileNo)
          VALUES (?, ?, ?, ?)
        ''', [
          contactJson['name'],
          contactJson['post'],
          contactJson['pic_url'],
          contactJson['phone'],
        ]);
      }
    });

    await _keeper.reset(PrefKeys.contactsRefresh);

    await _populateCache();
  }

  Future<void> _populateCache() async {
    _cache.clear();

    final rows = await _db.rawQuery('''
      SELECT name, post, photoUrl, mobileNo
        FROM Contact
    ''');

    for (var row in rows) {
      _cache.add(Contact(
        name: row['name'],
        post: row['post'],
        photoUrl: row['photoUrl'],
        mobileNo: row['mobileNo'],
      ));
    }
  }
}
