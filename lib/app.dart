import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoppermost/auth_wrapper.dart';
import 'cubit/auth/auth_cubit.dart';
import 'cubit/api/api_cubit.dart';
import 'cubit/shopping/shopping_cubit.dart';
import 'cubit/theme/theme_cubit.dart';
import 'screens/shopping_list_screen.dart';
import 'theme/app_theme.dart';

/// This app connects to a self-hosted Mattermost instance and shows messages
/// from a specific channel as a shopping list. Messages without reactions are
/// shown as items to buy, messages with a thumbs up reaction are shown as bought.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ApiCubit()),
        BlocProvider(
          create: (context) => AuthCubit(context.read<ApiCubit>()),
        ),
        BlocProvider(
          create: (context) => ShoppingCubit(context.read<ApiCubit>().api),
        ),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Shoppermost',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const AuthWrapper(),
            routes: {
              '/shopping_list': (context) => const ShoppingListScreen(),
            },
          );
        },
      ),
    );
  }
}
