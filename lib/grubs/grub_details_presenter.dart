import 'package:flutter/foundation.dart';
import 'package:messapp/grubs/grub_details.dart';
import 'package:messapp/grubs/grub_repository.dart';
import 'package:messapp/util/ui_state.dart';

class GrubDetailsPresenter with ChangeNotifier {
  GrubDetailsPresenter({
    @required GrubRepository repository,
    @required this.grubId,
  }) : this._repo = repository {
    notifyListeners();
    _repo.grubDetails(grubId: grubId).then((details) {
      _state = Success(details);
      notifyListeners();
    }).catchError((error) {
      _state = Failure(error.toString());
      notifyListeners();
    });
  }

  final int grubId;
  final GrubRepository _repo;
  UiState<GrubDetails> _state = Loading();

  UiState<GrubDetails> get state => _state;

  Future<void> restart() async {
    _state = Loading();
    notifyListeners();
    try {
      _state = Success(await _repo.grubDetails(grubId: grubId));
      notifyListeners();
    } on Exception catch (e) {
      _state = Failure(e.toString());
      notifyListeners();
    }
  }

  Future<void> signUp({
    @required int offeringId,
  }) async {
    final originalState = _state;
    _state = Loading();
    notifyListeners();
    try {
      await _repo.signUp(offeringId: offeringId);
      _state = Success(await _repo.grubDetails(grubId: grubId));
      notifyListeners();
    } on Exception catch (e) {
      print(e.toString());
      _state = originalState;
      notifyListeners();
      throw e;
    }
  }

  Future<void> cancel() async {
    final originalState = _state;
    _state = Loading();
    notifyListeners();
    try {
      await _repo.cancel(grubId: grubId);
      _state = Success(await _repo.grubDetails(grubId: grubId));
      notifyListeners();
    } on Exception catch (e) {
      _state = originalState;
      notifyListeners();
      throw e;
    }
  }
}
