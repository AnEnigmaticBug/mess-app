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
}
