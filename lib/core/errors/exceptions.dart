// Exception de base pour toutes les exceptions de l'application
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  const AppException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() {
    return 'AppException: $message${statusCode != null ? ' (code: $statusCode)' : ''}';
  }
}

// Exceptions liées au serveur
class ServerException extends AppException {
  const ServerException({
    String message = 'Erreur serveur',
    int? statusCode,
    dynamic error,
  }) : super(message: message, statusCode: statusCode, error: error);
}

class BadRequestException extends ServerException {
  const BadRequestException({
    String message = 'Requête invalide',
    dynamic error,
  }) : super(message: message, statusCode: 400, error: error);
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException({
    String message = 'Non autorisé',
    dynamic error,
  }) : super(message: message, statusCode: 401, error: error);
}

class ForbiddenException extends ServerException {
  const ForbiddenException({
    String message = 'Accès refusé',
    dynamic error,
  }) : super(message: message, statusCode: 403, error: error);
}

class NotFoundException extends ServerException {
  const NotFoundException({
    String message = 'Ressource non trouvée',
    dynamic error,
  }) : super(message: message, statusCode: 404, error: error);
}

class ConflictException extends ServerException {
  const ConflictException({
    String message = 'Conflit détecté',
    dynamic error,
  }) : super(message: message, statusCode: 409, error: error);
}

class InternalServerErrorException extends ServerException {
  const InternalServerErrorException({
    String message = 'Erreur interne du serveur',
    dynamic error,
  }) : super(message: message, statusCode: 500, error: error);
}

// Exceptions liées au cache
class CacheException extends AppException {
  const CacheException({
    String message = 'Erreur de cache',
    dynamic error,
  }) : super(message: message, error: error);
}

// Exceptions liées au réseau
class NetworkException extends AppException {
  const NetworkException({
    String message = 'Erreur réseau',
    dynamic error,
  }) : super(message: message, error: error);
}

class NoInternetException extends NetworkException {
  const NoInternetException({
    String message = 'Pas de connexion internet',
    dynamic error,
  }) : super(message: message, error: error);
}

class TimeoutException extends NetworkException {
  const TimeoutException({
    String message = 'Temps d\'attente dépassé',
    dynamic error,
  }) : super(message: message, error: error);
}

// Exceptions liées aux données
class DataParsingException extends AppException {
  const DataParsingException({
    String message = 'Erreur de parsing des données',
    dynamic error,
  }) : super(message: message, error: error);
}

class InvalidDataException extends AppException {
  const InvalidDataException({
    String message = 'Données invalides',
    dynamic error,
  }) : super(message: message, error: error);
}

// Exceptions d'authentification
class AuthenticationException extends AppException {
  const AuthenticationException({
    String message = 'Erreur d\'authentification',
    dynamic error,
  }) : super(message: message, error: error);
}

class TokenExpiredException extends AuthenticationException {
  const TokenExpiredException({
    String message = 'Token expiré',
    dynamic error,
  }) : super(message: message, error: error);
}

// Exceptions de validation
class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException({
    String message = 'Erreur de validation',
    required this.errors,
    dynamic error,
  }) : super(message: message, error: error);

  @override
  String toString() {
    return 'ValidationException: $message - Errors: $errors';
  }
}