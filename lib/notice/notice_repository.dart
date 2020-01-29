import 'dart:convert';

import 'package:messapp/notice/notice.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:messapp/util/simple_repository.dart';
import 'package:messapp/util/time_keeper.dart';
import 'package:meta/meta.dart';
import 'package:nice/nice.dart';
import 'package:sqflite/sqflite.dart';

class NoticeRepository extends SimpleRepository {
  NoticeRepository({
    @required Database database,
    @required NiceClient client,
    @required TimeKeeper keeper,
  })  : this._db = database,
        this._client = client,
        this._keeper = keeper;

  final Database _db;
  final NiceClient _client;
  final TimeKeeper _keeper;
  List<Notice> _cache = [];

  Future<List<Notice>> get notices async {
    if (_cache.isEmpty) {
      await _populateCache();
    }

    if (_cache.isEmpty || await _keeper.isDue(PrefKeys.noticesRefresh)) {
      await refresh();
    }

    return _cache;
  }

  Future<void> refresh() async {
    final response = await _client.get('/notice/valid/');

    if (response.statusCode != 200) {
      throw response.toException();
    }

    final noticesJson = json.decode(response.body) as List<dynamic>;

    await _db.transaction((txn) async {
      await txn.rawDelete('''
        DELETE
          FROM Notices
      ''');

      for (var noticeJson in noticesJson) {
        await txn.rawInsert('''
          INSERT
            INTO Notices (id, body, heading, startDate, endDate, isCritical)
          VALUES (?, ?, ?, ?, ?, ?)
        ''', [
          noticeJson['id'],
          noticeJson['body'],
          noticeJson['heading'],
          noticeJson['start_date'],
          noticeJson['end_date'],
          noticeJson['notice_type'] == 'C',
        ]);
      }
    });

    await _keeper.reset(PrefKeys.noticesRefresh);

    await _populateCache();
  }

  Future<void> _populateCache() async {
    final notices = _cache;
    notices.clear();

    final rows = await _db.rawQuery('''
      SELECT id, body, heading, startDate, isCritical
        FROM Notices
       ORDER BY startDate
    ''');

    for (var row in rows) {
      notices.add(Notice(
        id: row['id'],
        body: row['body'],
        heading: row['heading'],
        startDate: Date.parse(row['startDate']),
        isCritical: row['isCritical'] == 1,
      ));
    }
  }
}
