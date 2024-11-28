import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoppermost/cubit/auth/auth_cubit.dart';
import 'package:shoppermost/cubit/auth/auth_state.dart';
import 'package:shoppermost/screens/login_screen.dart';
import 'package:shoppermost/screens/shopping_list_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check credentials after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkStoredCredentials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return const ShoppingListScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
