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
      await _getCache();
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
          DELETE FROM Notices
      ''');

      for (var noticeJson in noticesJson) {
        await txn.rawInsert('''
          INSERT INTO Notices (id, body, heading, startDate, endDate, noticeType)
          VALUES (?, ?, ?, ?, ?, ?)''', [
          noticeJson['id'],
          noticeJson['body'],
          noticeJson['heading'],
          noticeJson['start_date'],
          noticeJson['end_date'],
          noticeJson['notice_type']
        ]);
      }
    });

    await _keeper.reset(PrefKeys.noticesRefresh);

    await _getCache();
  }

  Future<List<Map<String, dynamic>>> get _dbNotices async {
    return await _db.rawQuery('''
      SELECT id, body, heading, startDate, 
        CASE
          WHEN noticeType = 'C' THEN 1
          WHEN noticeType = 'N' THEN 0
          ELSE 0
        END AS isCritical
      FROM Notices
      ORDER BY startDate
    ''');
  }

  Future<void> _getCache() async {
    final notices = _cache;
    notices.clear();

    for (var row in await _dbNotices) {

//      switch (row['startDate'].toString().substring(5, 7)) {
//        case '01':
//          {
//            date = 'January ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '02':
//          {
//            date = 'February ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '03':
//          {
//            date = 'March ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '04':
//          {
//            date = 'April ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '05':
//          {
//            date = 'May ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '06':
//          {
//            date = 'June ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '07':
//          {
//            date = 'July ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '08':
//          {
//            date = 'August ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '09':
//          {
//            date = 'September ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '10':
//          {
//            date = 'October ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '11':
//          {
//            date = 'November ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        case '12':
//          {
//            date = 'December ${row['startDate'].toString().substring(8)}';
//          }
//          break;
//
//        default:
//          {
//            date = row['startDate'].toString().substring(5);
//          }

      notices.add(Notice(
          id: row['id'],
          body: row['body'],
          heading: row['heading'],
          startDate: Date.parse(row['startDate']),
          isCritical: row['isCritical']));
    }
  }
}
