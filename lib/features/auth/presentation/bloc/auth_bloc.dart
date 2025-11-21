import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _authRepository;

  AuthBloc()
      : _authRepository = AuthRepositoryImpl(),
        super(AuthInitial()) {

    print('🔄 AuthBloc created with initial state: $state');

    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    print('🔄 AuthBloc: Processing LoginEvent for ${event.email}');
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(event.email, event.password);
      print('✅ AuthBloc: Login successful, emitting AuthAuthenticated');
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      print('❌ AuthBloc: Login error, emitting AuthError: $e');
      emit(AuthError(e.toString()));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}