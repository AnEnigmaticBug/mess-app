import 'package:flutter/cupertino.dart';
import 'package:messapp/profile/profile.dart';
import 'package:messapp/profile/profile_repository.dart';
import 'package:messapp/util/ui_state.dart';

class ProfilePresenter extends ChangeNotifier{

  final ProfileRepository _repo;
  UiState<Profile> _state = Loading();

  ProfilePresenter(ProfileRepository repository): this._repo = repository{}

  UiState<Profile> get state => _state;

  void getProfile() {
    _repo.profileInfo.then((profile) {
      _state = Success(profile);
      notifyListeners();
    }).catchError((error) {
      _state = Failure(error.toString());
      notifyListeners();
    });
  }

  Future<void> refreshQr() async {
    _state = Loading();
    notifyListeners();
    await _repo.refresh();
    getProfile();
  }

  Future<void> logout() async {

  }

  Future<void> restart() async {
    _state = Loading();
    notifyListeners();
    try {
      getProfile();
    } on Exception catch (e) {
      _state = Failure(e.toString());
      notifyListeners();
    }
  }

}