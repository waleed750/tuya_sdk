class Result<T> {
  final T? data;
  final String? error;

  Result({this.data, this.error});

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  factory Result.success(T data) => Result(data: data);
  factory Result.failure(String error) => Result(error: error);
}