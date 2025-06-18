import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:wizi_learn/core/exceptions/auth_exception.dart';
import 'package:wizi_learn/features/auth/data/repositories/auth_repository_contract.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_event.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryContract authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(Authenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
      emit(Unauthenticated()); // Retour à l'état non authentifié après erreur
    } catch (e) {
      emit(AuthError('Une erreur inattendue est survenue'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated()); // Force la déconnexion même en cas d'erreur
    }
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await authRepository.isLoggedIn()
          .timeout(const Duration(seconds: 5)); // Timeout après 5 secondes

      if (!isLoggedIn) {
        emit(Unauthenticated());
        return;
      }

      final user = await authRepository.getMe()
          .timeout(const Duration(seconds: 5)); // Timeout pour getMe aussi

      emit(Authenticated(user));
    } on TimeoutException {
      emit(Unauthenticated());
    } on AuthException catch (_) {
      await authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('Erreur inattendue'));
      emit(Unauthenticated());
    }
  }
}