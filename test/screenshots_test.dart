import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shoppermost/cubit/auth/auth_cubit.dart';
import 'package:shoppermost/cubit/auth/auth_state.dart';
import 'package:shoppermost/cubit/shopping/shopping_cubit.dart';
import 'package:shoppermost/cubit/shopping/shopping_state.dart';
import 'package:shoppermost/cubit/theme/theme_cubit.dart';
import 'package:shoppermost/models/shopping_item.dart';
import 'package:shoppermost/screens/login_screen.dart';
import 'package:shoppermost/screens/shopping_list_screen.dart';
import 'package:shoppermost/screens/settings_screen.dart';
import 'package:shoppermost/theme/app_theme.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockShoppingCubit extends MockCubit<ShoppingState>
    implements ShoppingCubit {}

class MockThemeCubit extends MockCubit<ThemeMode> implements ThemeCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue('');
  });

  final sampleItems = [
    ShoppingItem(id: '1', text: 'Whole milk'),
    ShoppingItem(id: '2', text: 'Sourdough bread'),
    ShoppingItem(id: '3', text: 'Free-range eggs'),
    ShoppingItem(id: '4', text: 'Unsalted butter'),
    ShoppingItem(id: '5', text: 'Fresh basil'),
    ShoppingItem(id: '6', text: 'Cherry tomatoes'),
    ShoppingItem(id: '7', text: 'Parmesan cheese', isInCart: true),
    ShoppingItem(id: '8', text: 'Olive oil', isInCart: true),
  ];

  final sampleChannels = <Map<String, dynamic>>[
    {
      'id': 'ch1',
      'display_name': 'Grocery Shopping',
      'name': 'grocery-shopping'
    },
    {
      'id': 'ch2',
      'display_name': 'Weekly Meals',
      'name': 'weekly-meals'
    },
  ];

  late MockAuthCubit mockAuth;
  late MockShoppingCubit mockShopping;
  late MockThemeCubit mockTheme;

  void setupMocks({ThemeMode themeMode = ThemeMode.light}) {
    mockAuth = MockAuthCubit();
    mockShopping = MockShoppingCubit();
    mockTheme = MockThemeCubit();

    when(() => mockAuth.state).thenReturn(AuthInitial());

    when(() => mockShopping.state).thenReturn(ShoppingLoaded(sampleItems));
    when(() => mockShopping.loadItems()).thenAnswer((_) async {});
    when(() => mockShopping.loadItems(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async {});
    when(() => mockShopping.channelId).thenReturn('ch1');
    when(() => mockShopping.getChannels())
        .thenAnswer((_) async => sampleChannels);
    when(() => mockShopping.setChannel(any())).thenAnswer((_) async {});

    when(() => mockTheme.state).thenReturn(themeMode);
    when(() => mockTheme.setThemeMode(any())).thenAnswer((_) async {});
  }

  void configureScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2.0;
  }

  Widget wrapScreen(Widget screen, {required bool isDark}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: mockAuth),
          BlocProvider<ShoppingCubit>.value(value: mockShopping),
          BlocProvider<ThemeCubit>.value(value: mockTheme),
        ],
        child: screen,
      ),
    );
  }

  group('Screenshots', () {
    for (final isDark in [false, true]) {
      final suffix = isDark ? 'dark' : 'light';

      testWidgets('login_$suffix', (tester) async {
        configureScreen(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        setupMocks(
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light);

        await tester.pumpWidget(
            wrapScreen(const LoginScreen(), isDark: isDark));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/login_$suffix.png'),
        );
      });

      testWidgets('shopping_$suffix', (tester) async {
        configureScreen(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        setupMocks(
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light);

        await tester.pumpWidget(
            wrapScreen(const ShoppingListScreen(), isDark: isDark));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/shopping_$suffix.png'),
        );
      });

      testWidgets('settings_$suffix', (tester) async {
        configureScreen(tester);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        setupMocks(
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light);

        await tester.pumpWidget(
            wrapScreen(const SettingsScreen(), isDark: isDark));
        await tester.pump(); // let _loadChannels() future resolve
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/settings_$suffix.png'),
        );
      });
    }
  });
}
