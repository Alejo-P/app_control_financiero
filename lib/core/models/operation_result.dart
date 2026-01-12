/// Representa el resultado de una operación, incluyendo éxito, datos y mensaje. (Genérico)
class OperationResult<T> {
  final bool success;
  final T? data;
  final String message;

  const OperationResult({
    required this.success,
    this.data,
    required this.message,
  });
}
