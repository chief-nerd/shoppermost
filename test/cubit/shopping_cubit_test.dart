import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shoppermost/cubit/shopping/shopping_cubit.dart';
import 'package:shoppermost/cubit/shopping/shopping_state.dart';
import 'package:shoppermost/services/mattermost_api.dart';
import 'package:shoppermost/services/database_service.dart';
import 'package:shoppermost/models/shopping_item.dart';

class MockMattermostApi extends Mock implements MattermostApi {}

class MockDatabaseService extends Mock implements DatabaseService {}

class FakeShoppingItem extends Fake implements ShoppingItem {}

void main() {
  late ShoppingCubit shoppingCubit;
  late MockMattermostApi mockApi;
  late MockDatabaseService mockDb;

  setUpAll(() {
    registerFallbackValue(FakeShoppingItem());
  });

  setUp(() {
    mockApi = MockMattermostApi();
    mockDb = MockDatabaseService();
    shoppingCubit = ShoppingCubit(mockApi, db: mockDb);
  });

  tearDown(() {
    shoppingCubit.close();
  });

  group('ShoppingCubit', () {
    blocTest<ShoppingCubit, ShoppingState>(
      'loadItems emits [ShoppingLoading, ShoppingLoaded] when data exists in DB',
      setUp: () {
        when(() => mockDb.getItems()).thenAnswer((_) async => [
              ShoppingItem(id: '1', text: 'Milk'),
            ]);
        when(() => mockApi.getSavedChannelId())
            .thenAnswer((_) async => 'chan1');
        when(() => mockApi.getChannelMessages(any()))
            .thenAnswer((_) async => <Map<String, dynamic>>[]);
        when(() => mockDb.clearItems()).thenAnswer((_) async => {});
        when(() => mockDb.insertItems(any())).thenAnswer((_) async => {});
      },
      build: () => shoppingCubit,
      act: (cubit) => cubit.loadItems(),
      expect: () => [
        isA<ShoppingLoading>(),
        isA<ShoppingLoaded>(), // Initial load from DB
        isA<ShoppingLoaded>(), // Update from API (empty list)
      ],
    );

    blocTest<ShoppingCubit, ShoppingState>(
      'loadItems splits multi-line messages and cleans prefixes',
      setUp: () {
        when(() => mockDb.getItems()).thenAnswer((_) async => <ShoppingItem>[]);
        when(() => mockApi.getSavedChannelId())
            .thenAnswer((_) async => 'chan1');
        when(() => mockApi.getChannelMessages(any())).thenAnswer((_) async => [
              {
                'id': 'msg1',
                'message': '- Eggs\n* Bread\n1. Milk',
                'metadata': {'reactions': []}
              }
            ]);
        when(() => mockDb.clearItems()).thenAnswer((_) async => {});
        when(() => mockDb.insertItems(any())).thenAnswer((_) async => {});
      },
      build: () => shoppingCubit,
      act: (cubit) => cubit.loadItems(),
      verify: (cubit) {
        final state = cubit.state as ShoppingLoaded;
        expect(state.items.length, 3);
        expect(state.items[0].text, 'Eggs');
        expect(state.items[1].text, 'Bread');
        expect(state.items[2].text, 'Milk');
      },
    );

    blocTest<ShoppingCubit, ShoppingState>(
      'addItem calls API and refreshes items',
      setUp: () {
        when(() => mockApi.getSavedChannelId())
            .thenAnswer((_) async => 'chan1');
        when(() => mockApi.postMessage(any(), any()))
            .thenAnswer((_) async => true);
        when(() => mockDb.getItems()).thenAnswer((_) async => <ShoppingItem>[]);
        when(() => mockApi.getChannelMessages(any()))
            .thenAnswer((_) async => <Map<String, dynamic>>[]);
        when(() => mockDb.clearItems()).thenAnswer((_) async => {});
        when(() => mockDb.insertItems(any())).thenAnswer((_) async => {});
      },
      build: () => shoppingCubit,
      act: (cubit) async {
        await cubit.loadItems(); // To set _channelId
        await cubit.addItem('Apples');
      },
      verify: (_) {
        verify(() => mockApi.postMessage('chan1', 'Apples')).called(1);
      },
    );
  });
}
