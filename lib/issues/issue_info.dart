import 'package:flutter/foundation.dart';
import 'package:messapp/issues/issue.dart';
import 'package:messapp/issues/issue_repository.dart';

@immutable
abstract class UiState {
  const UiState();
}

class Loading extends UiState {
  const Loading();
}

class Success extends UiState {
  const Success({
    @required this.recentIssues,
    @required this.popularIssues,
    @required this.solvedIssues,
  });

  final List<ActiveIssue> recentIssues;
  final List<ActiveIssue> popularIssues;
  final List<SolvedIssue> solvedIssues;
}

class Failure extends UiState {
  const Failure(this.error);

  final String error;
}

class IssueInfo with ChangeNotifier {
  IssueInfo(IssueRepository repository) : this._repo = repository {
    _repo.successState.then((success) {
      _state = success;
      notifyListeners();
    }).catchError((error) {
      _state = Failure(error.toString());
    });
  }

  final IssueRepository _repo;
  UiState _state = Loading();

  UiState get state => _state;

  Future<void> refresh() async {
    await _repo.refresh();
    _state = await _repo.successState;
    notifyListeners();
  }
}

extension on IssueRepository {
  Future<Success> get successState async {
    final active = await this.activeIssues;
    final solved = await this.solvedIssues;
    solved.sort((a, b) => -a.dateSolved.compareTo(b.dateSolved));
    final recent = List<ActiveIssue>.from(active);
    recent.sort((a, b) => -a.dateCreated.compareTo(b.dateCreated));
    final popular = List<ActiveIssue>.from(active);
    popular.sort((a, b) => -a.upvoteCount.compareTo(b.upvoteCount));

    return Success(
      recentIssues: recent,
      popularIssues: popular,
      solvedIssues: solved,
    );
  }
}
