import 'package:flutter/foundation.dart';
import 'package:messapp/util/extensions.dart';
import 'package:messapp/util/simple_repository.dart';
import 'package:messapp/util/ui_state.dart';

class SimplePresenter<R extends SimpleRepository, D> with ChangeNotifier {
  SimplePresenter({
    @required R repository,
    @required Future<D> Function(R) mapper,
  })  : this._repo = repository,
        this._mapper = mapper {
    restart();
  }

  final R _repo;
  final Future<D> Function(R) _mapper;
  UiState<D> _state = Loading();

  UiState get state => _state;

  Future<void> refresh() async {
    await _repo.refresh();
    _state = Success(await _mapper(_repo));
    notifyListeners();
  }

  Future<void> restart() async {
    _state = Loading();
    notifyListeners();
    try {
      _state = Success(await _mapper(_repo));
      notifyListeners();
    } on Exception catch (e) {
      _state = Failure(e.prettify());
      notifyListeners();
    }
  }
}
