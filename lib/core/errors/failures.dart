import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({String message = 'Server error'}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache error'}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'Network error'}) : super(message);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure({String message = 'Invalid input'}) : super(message);
}