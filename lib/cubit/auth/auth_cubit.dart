import 'package:flutter_bloc/flutter_bloc.dart';
import '../api/api_cubit.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiCubit _apiCubit;

  AuthCubit(this._apiCubit) : super(AuthInitial());

  Future<void> checkStoredCredentials() async {
    emit(AuthLoading());
    try {
      if (await _apiCubit.api.hasStoredCredentials()) {
        emit(AuthSuccess());
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> login(String server, String username, String password) async {
    emit(AuthLoading());
    try {
      final success = await _apiCubit.api.login(server, username, password);
      if (success) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure('Login failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
