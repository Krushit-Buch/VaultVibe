/// Base class for all domain-layer failures.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Failure from local data source (Hive).
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Failure when a requested item is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Failure caused by invalid input data.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Generic unexpected failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}
