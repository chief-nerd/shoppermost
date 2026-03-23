import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shoppermost/cubit/auth/auth_cubit.dart';
import 'package:shoppermost/cubit/auth/auth_state.dart';
import 'package:shoppermost/cubit/api/api_cubit.dart';
import 'package:shoppermost/services/mattermost_api.dart';

class MockMattermostApi extends Mock implements MattermostApi {}
class MockApiCubit extends Mock implements ApiCubit {}

void main() {
  late AuthCubit authCubit;
  late MockApiCubit mockApiCubit;
  late MockMattermostApi mockApi;

  setUp(() {
    mockApi = MockMattermostApi();
    mockApiCubit = MockApiCubit();
    when(() => mockApiCubit.api).thenReturn(mockApi);
    authCubit = AuthCubit(mockApiCubit);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthSuccess] when credentials exist',
      setUp: () {
        when(() => mockApi.hasStoredCredentials()).thenAnswer((_) async => true);
      },
      build: () => authCubit,
      act: (cubit) => cubit.checkStoredCredentials(),
      expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthInitial] when credentials dont exist',
      setUp: () {
        when(() => mockApi.hasStoredCredentials()).thenAnswer((_) async => false);
      },
      build: () => authCubit,
      act: (cubit) => cubit.checkStoredCredentials(),
      expect: () => [isA<AuthLoading>(), isA<AuthInitial>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful login',
      setUp: () {
        when(() => mockApi.login(any(), any(), any())).thenAnswer((_) async => true);
      },
      build: () => authCubit,
      act: (cubit) => cubit.login('server', 'user', 'pass'),
      expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] on failed login',
      setUp: () {
        when(() => mockApi.login(any(), any(), any())).thenAnswer((_) async => false);
      },
      build: () => authCubit,
      act: (cubit) => cubit.login('server', 'user', 'pass'),
      expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
    );
  });
}
