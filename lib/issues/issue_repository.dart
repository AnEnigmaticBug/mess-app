import 'dart:convert';

import 'package:messapp/issues/issue.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:meta/meta.dart';
import 'package:nice/nice.dart';
import 'package:sqflite/sqlite_api.dart';

class IssueRepository {
  IssueRepository({
    @required Database database,
    @required NiceClient client,
  })  : this._db = database,
        this._client = client;

  final Database _db;
  final NiceClient _client;
  List<ActiveIssue> _activeIssueCache = [];
  List<SolvedIssue> _solvedIssueCache = [];

  Future<List<ActiveIssue>> get activeIssues async {
    if (_activeIssueCache.isEmpty) {
      await _populateCaches();
    }

    return _activeIssueCache;
  }

  Future<List<SolvedIssue>> get solvedIssues async {
    if (_solvedIssueCache.isEmpty) {
      await _populateCaches();
    }

    return _solvedIssueCache;
  }

  Future<void> refresh() async {
    final res = await _client.get('/issues');

    if (res.statusCode != 200) {
      throw res.toException();
    }

    final issuesJson = json.decode(res.body);
    final activeIssuesJson = issuesJson['active'];
    final solvedIssuesJson = issuesJson['solved'];

    await _db.transaction((txn) async {
      await txn.rawDelete('''
        DELETE
          FROM ActiveIssue
      ''');

      await txn.rawDelete('''
        DELETE
          FROM SolvedIssue
      ''');

      for (var issueJson in activeIssuesJson) {
        await txn.rawInsert('''
          INSERT
            INTO ActiveIssue (id, title, dateCreated, upvoteCount, upvoted, flagged)
          VALUES (?, ?, ?, ?, ?, ?)
        ''', [
          issueJson['id'],
          issueJson['title'],
          issueJson['date_created'],
          issueJson['upvote_count'],
          issueJson['upvoted'] ? 1 : 0,
          issueJson['flagged'] ? 1 : 0,
        ]);
      }

      for (var issueJson in solvedIssuesJson) {
        await txn.rawInsert('''
          INSERT
            INTO SolvedIssue (id, title, dateCreated, upvoteCount, upvoted, flagged, dateSolved, reason)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          issueJson['id'],
          issueJson['title'],
          issueJson['date_created'],
          issueJson['upvote_count'],
          issueJson['upvoted'] ? 1 : 0,
          issueJson['flagged'] ? 1 : 0,
          issueJson['date_solved'],
          issueJson['reason'],
        ]);
      }
    });

    await _populateCaches();
  }

  Future<void> setUpvoted({
    @required int issueId,
    @required bool value,
  }) async {
    await _db.transaction((txn) async {
      if (value) {
        await txn.execute('''
          UPDATE ActiveIssue
             SET upvoted = ?,
                 upvoteCount = upvoteCount + 1
          WHERE id = ?
        ''', [1, issueId]);
      } else {
        await txn.execute('''
          UPDATE ActiveIssue
             SET upvoted = ?,
                 upvoteCount = upvoteCount - 1
          WHERE id = ?
        ''', [0, issueId]);
      }

      final reqBody = json.encode([
        {
          'issue_id': issueId,
          'value': value,
        },
      ]);
      final res = await _client.post('/set-upvoted', body: reqBody);

      if (res.statusCode != 200) {
        throw res.toException();
      }
    });
  }

  Future<void> setFlagged({
    @required int issueId,
    @required bool value,
  }) async {
    await _db.transaction((txn) async {
      await txn.execute('''
        UPDATE ActiveIssue
           SET flagged = ?
        WHERE id = ?
      ''', [value ? 1 : 0, issueId]);

      final reqBody = json.encode([
        {
          'issue_id': issueId,
          'value': value,
        },
      ]);
      final res = await _client.post('/set-flagged', body: reqBody);

      if (res.statusCode != 200) {
        throw res.toException();
      }
    });
  }

  Future<void> createIssue(String title) async {
    final reqBody = json.encode({'title': title});
    final res = await _client.post('/issues', body: reqBody);

    if (res.statusCode != 200) {
      throw res.toException();
    }
  }

  Future<void> _populateCaches() async {
    await _populateActiveIssueCache();
    await _populateSolvedIssueCache();
  }

  Future<void> _populateActiveIssueCache() async {
    _activeIssueCache.clear();

    final rows = await _db.rawQuery('''
      SELECT id, title, dateCreated, upvoteCount, upvoted, flagged
        FROM ActiveIssue
    ''');

    for (var row in rows) {
      _activeIssueCache.add(ActiveIssue(
        id: row['id'],
        title: row['title'],
        dateCreated: Date.parse(row['dateCreated']),
        upvoteCount: row['upvoteCount'],
        upvoted: row['upvoted'] == 1,
        flagged: row['flagged'] == 1,
        repository: this,
      ));
    }
  }

  Future<void> _populateSolvedIssueCache() async {
    _solvedIssueCache.clear();

    final rows = await _db.rawQuery('''
      SELECT id, title, dateCreated, upvoteCount, upvoted, flagged, dateSolved, reason
        FROM SolvedIssue
    ''');

    for (var row in rows) {
      _solvedIssueCache.add(SolvedIssue(
        id: row['id'],
        title: row['title'],
        dateCreated: Date.parse(row['dateCreated']),
        upvoteCount: row['upvoteCount'],
        upvoted: row['upvoted'] == 1,
        flagged: row['flagged'] == 1,
        dateSolved: Date.parse(row['dateSolved']),
        reason: row['reason'],
        repository: this,
      ));
    }
  }
}
