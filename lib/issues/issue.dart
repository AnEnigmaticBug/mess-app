import 'package:flutter/foundation.dart';
import 'package:messapp/issues/issue_repository.dart';
import 'package:messapp/util/date.dart';
import 'package:meta/meta.dart';

@sealed
abstract class Issue with ChangeNotifier {
  Issue({
    @required this.id,
    @required this.title,
    @required this.dateCreated,
    @required int upvoteCount,
    @required bool upvoted,
    @required bool flagged,
    @required IssueRepository repository,
  })  : this._upvoteCount = upvoteCount,
        this._upvoted = upvoted,
        this._flagged = flagged,
        this._repo = repository;

  final int id;
  final String title;
  final Date dateCreated;
  final IssueRepository _repo;
  int _upvoteCount;
  bool _upvoted;
  bool _flagged;

  int get upvoteCount => _upvoteCount;

  bool get upvoted => _upvoted;

  bool get flagged => _flagged;

  Future<void> setUpvoted(bool value) async {
    _upvoted = value;
    if (_upvoted) {
      _upvoteCount += 1;
    } else {
      _upvoteCount -= 1;
    }
    notifyListeners();
    await _repo.setUpvoted(issueId: id, value: value);
  }

  Future<void> setFlagged(bool value) async {
    _flagged = value;
    notifyListeners();
    await _repo.setFlagged(issueId: id, value: value);
  }
}

class ActiveIssue extends Issue {
  ActiveIssue({
    @required int id,
    @required String title,
    @required Date dateCreated,
    @required int upvoteCount,
    @required bool upvoted,
    @required bool flagged,
    @required IssueRepository repository,
  }) : super(
          id: id,
          title: title,
          dateCreated: dateCreated,
          upvoteCount: upvoteCount,
          upvoted: upvoted,
          flagged: flagged,
          repository: repository,
        );
}

class SolvedIssue extends Issue {
  SolvedIssue({
    @required int id,
    @required String title,
    @required Date dateCreated,
    @required int upvoteCount,
    @required bool upvoted,
    @required bool flagged,
    @required this.reason,
    @required this.dateSolved,
    @required IssueRepository repository,
  }) : super(
          id: id,
          title: title,
          dateCreated: dateCreated,
          upvoteCount: upvoteCount,
          upvoted: upvoted,
          flagged: flagged,
          repository: repository,
        );

  final String reason;
  final Date dateSolved;
}
