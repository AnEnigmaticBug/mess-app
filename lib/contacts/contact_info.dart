import 'package:flutter/foundation.dart';
import 'package:messapp/contacts/contact.dart';
import 'package:messapp/contacts/contact_repository.dart';

@immutable
abstract class UiState {
  const UiState();
}

class Loading extends UiState {
  const Loading();
}

class Success extends UiState {
  const Success(this.contacts);

  final List<Contact> contacts;
}

class Failure extends UiState {
  const Failure(this.error);

  final String error;
}

class ContactInfo with ChangeNotifier {
  ContactInfo(ContactRepository repository) : this._repo = repository {
    _repo.contacts.then((contacts) {
      _state = Success(contacts);
      notifyListeners();
    }).catchError((error) {
      _state = Failure(error.toString());
      notifyListeners();
    });
  }

  final ContactRepository _repo;
  UiState _state = Loading();

  UiState get state => _state;

  Future<void> refresh() async {
    try {
      await _repo.refresh();
      _state = Success(await _repo.contacts);
      notifyListeners();
    } on Exception {}
  }
}
