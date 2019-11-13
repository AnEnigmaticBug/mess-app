import 'package:flutter/foundation.dart';
import 'package:messapp/menu/menu.dart';
import 'package:messapp/menu/menu_repository.dart';

@immutable
abstract class UiState {
  const UiState();
}

class Loading extends UiState {
  const Loading();
}

class Success extends UiState {
  const Success(this.menus);

  final List<Menu> menus;
}

class Failure extends UiState {
  const Failure(this.error);

  final String error;
}

class MenuInfo with ChangeNotifier {
  MenuInfo(MenuRepository repository) : this._repo = repository {
    _repo.menus.then((menus) {
      _state = Success(menus);
      notifyListeners();
    }).catchError((error) {
      _state = Failure(error.toString());
      notifyListeners();
    });
  }

  final MenuRepository _repo;
  UiState _state = Loading();

  UiState get state => _state;

  Future<void> refresh() async {
    try {
      await _repo.refresh();
      _state = Success(await _repo.menus);
      notifyListeners();
    } on Exception {}
  }
}
