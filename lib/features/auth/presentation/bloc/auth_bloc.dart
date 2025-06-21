import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:wizi_learn/core/exceptions/auth_exception.dart';
import 'package:wizi_learn/features/auth/data/repositories/auth_repository_contract.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_event.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryContract authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(Authenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
      emit(Unauthenticated());
    } on TimeoutException {
      emit(AuthError('Timeout: Le serveur a mis trop de temps à répondre'));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('Une erreur inattendue est survenue: ${e.toString()}'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(Unauthenticated());
    } on AuthException {
      // Même en cas d'erreur, on considère l'utilisateur comme déconnecté
      emit(Unauthenticated());
    } catch (e) {
      // On force la déconnexion même en cas d'erreur inattendue
      emit(Unauthenticated());
    }
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await authRepository.isLoggedIn()
          .timeout(const Duration(seconds: 5));

      if (!isLoggedIn) {
        emit(Unauthenticated());
        return;
      }

      final user = await authRepository.getMe()
          .timeout(const Duration(seconds: 5));

      emit(Authenticated(user));
    } on TimeoutException {
      emit(AuthError('Timeout: Vérification de l\'authentification trop longue'));
      emit(Unauthenticated());
    } on AuthException catch (e) {
      // Si getMe échoue avec une AuthException, on déconnecte proprement
      await authRepository.logout();
      emit(AuthError(e.message));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('Erreur inattendue lors de la vérification: ${e.toString()}'));
      emit(Unauthenticated());
    }
  }
}