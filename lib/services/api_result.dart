sealed class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  });
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return success(data);
  }
}

class Failure<T> extends ApiResult<T> {
  final String message;
  const Failure(this.message);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return failure(message);
  }
}
