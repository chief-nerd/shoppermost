import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoppermost/auth_wrapper.dart';
import 'cubit/auth/auth_cubit.dart';
import 'cubit/api/api_cubit.dart';
import 'cubit/shopping/shopping_cubit.dart';
import 'screens/shopping_list_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'Shoppermost',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(103, 58, 183, 1)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/shopping_list': (context) => const ShoppingListScreen(),
        },
      ),
    );
  }
}
