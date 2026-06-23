abstract class Failure {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class ParsingFailure extends Failure {
  const ParsingFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message) : super(code: 401);
}
