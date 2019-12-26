import 'package:meta/meta.dart';
import 'package:messapp/notice/notice.dart';
import 'package:nice/nice.dart';
import 'package:sqflite/sqflite.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'dart:convert';

class NoticeRepository {
  NoticeRepository({
    @required Database database,
    @required NiceClient client,
  }) : this._db = database,
       this._client = client;

  Database _db;
  NiceClient _client;
  List<Notice> _cache = [];

  Future<List<Notice>> get notices async {
    if(_cache.isNotEmpty) {
      return _cache;
    }

    await refreshCache();
    await _getCache();
    return _cache;
  }
  
  Future<void> refreshCache() async {
    final response = await _client.get('/notice/valid/');

    if (response.statusCode != 200){
      throw response.toException();
    }

    final noticesJson = json.decode(response.body) as List<dynamic>;

    await _db.transaction((txn) async {

      await txn.rawDelete('''
          DELETE FROM Notices
      ''');

      for(var noticeJson in noticesJson) {
        await txn.rawInsert('''
          INSERT INTO Notices (id, body, heading, startDate, endDate, noticeType)
          VALUES (?, ?, ?, ?, ?, ?)''',
          [noticeJson['id'], noticeJson['body'], noticeJson['heading'], noticeJson['start_date'], noticeJson['end_date'], noticeJson['notice_type']]);
      }

    });

    await _getCache();
  }

  Future<List<Map<String, dynamic>>> get _dbNotices async{
    return await _db.rawQuery('''
      SELECT id, body, heading, startDate, 
        CASE
          WHEN noticeType = 'C' THEN true
          WHEN noticeType = 'N' THEN false
        END AS isCritical
      FROM Notices
      ORDER BY startDate
    ''');
  }

  Future<void> _getCache() async{
    final notices = _cache;
    notices.clear();

    for(var row in await _dbNotices){

      notices.add(Notice(
        id: row['id'],
        body: row['body'],
        heading: row['heading'],
        startDate: row['startDate'],
        isCritical: row['isCritical']
      ));
    }
  }
}