import 'package:flutter/foundation.dart';
import 'package:messapp/notice/notice.dart';
import 'package:messapp/notice/notice_repository.dart';

@immutable
abstract class UiState{
  const UiState();
}

class Loading extends UiState{
  const Loading();
}

class Success extends UiState{
  const Success(this.notices);
  final List<Notice> notices;
}

class Failure extends UiState{
  const Failure(this.error);
  final String error;
}

class NoticeInfo with ChangeNotifier {
  NoticeInfo(NoticeRepository repository): this._repo = repository {
    _repo.notices.then((notices) {
      _state = Success(notices);
      notifyListeners();
    }).catchError((error) {
      _state = Failure(error.toString());
      notifyListeners();
    });
  }

  final NoticeRepository _repo;
  UiState _state = Loading();

  UiState get state => _state;

  Future<void> refresh() async {
    try{
      await _repo.refreshCache();
      _state = Success(await _repo.notices);
      notifyListeners();
    } on Exception {}
  }
}