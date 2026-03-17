sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  });

  Result<R> map<R>(R Function(T value) transform) => fold(
        onSuccess: (value) => Success(transform(value)),
        onFailure: Failure.new,
      );
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) =>
      onSuccess(value);
}

class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppError error;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) =>
      onFailure(error);
}

sealed class AppError {
  const AppError(this.message);

  final String message;
}

class ValidationError extends AppError {
  const ValidationError(super.message);
}

class NotFoundError extends AppError {
  const NotFoundError(super.message);
}

class DatabaseError extends AppError {
  const DatabaseError(super.message);
}
