import 'package:meta/meta.dart';

@sealed
abstract class UiState<T> {
  const UiState();
}

class Loading<T> extends UiState<T> {
  const Loading();
}

class Success<T> extends UiState<T> {
  const Success(this.data);

  final T data;
}

class Failure<T> extends UiState<T> {
  const Failure(this.message);

  final String message;
}
