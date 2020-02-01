import 'package:flutter/foundation.dart';
import 'package:messapp/profile/profile.dart';
import 'package:messapp/profile/profile_repository.dart';
import 'package:messapp/util/extensions.dart';
import 'package:messapp/util/ui_state.dart';

class ProfilePresenter extends ChangeNotifier {
  ProfilePresenter(ProfileRepository repository) : this._repo = repository {
    restart();
  }

  final ProfileRepository _repo;
  UiState<Profile> _state = Loading();

  UiState<Profile> get state => _state;

  Future<void> refreshQr() async {
    final original = state;
    _state = Loading();
    notifyListeners();

    try {
      await _repo.refreshQr();
      await restart();
    } on Exception catch (e) {
      _state = original;
      notifyListeners();
      throw e;
    }
  }

  Future<void> logout() async {
    _state = Loading();
    notifyListeners();
    await _repo.logout();
  }

  Future<void> restart() async {
    _state = Loading();
    notifyListeners();
    try {
      _state = Success(await _repo.profile);
      notifyListeners();
    } on Exception catch (e) {
      _state = Failure(e.prettify());
      notifyListeners();
    }
  }
}
