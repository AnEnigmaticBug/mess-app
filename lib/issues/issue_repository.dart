import 'package:messapp/issues/issue.dart';
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

  Future<void> setUpvoted({
    @required int issueId,
    @required bool value,
  }) async {}

  Future<void> setFlagged({
    @required int issueId,
    @required bool value,
  }) async {}
}
