sealed class AppResult<T> {
  const AppResult();

  R when<R>({
    required R Function(T value) ok,
    required R Function(AppError error) err,
  }) {
    if (this is Ok<T>) {
      return ok((this as Ok<T>).value);
    }
    return err((this as Err<T>).error);
  }
}

class Ok<T> extends AppResult<T> {
  final T value;

  const Ok(this.value);
}

class Err<T> extends AppResult<T> {
  final AppError error;

  const Err(this.error);
}

sealed class AppError {
  final String message;

  const AppError(this.message);
}

class ValidationError extends AppError {
  const ValidationError(String message) : super(message);
}

class NotFoundError extends AppError {
  const NotFoundError(String message) : super(message);
}

class DatabaseError extends AppError {
  const DatabaseError(String message) : super(message);
}
