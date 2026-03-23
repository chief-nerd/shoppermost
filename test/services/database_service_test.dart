import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shoppermost/services/database_service.dart';
import 'package:shoppermost/models/shopping_item.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DatabaseService', () {
    late DatabaseService dbService;

    setUp(() {
      dbService = DatabaseService(dbPath: inMemoryDatabasePath);
    });

    test('insertItems and getItems works', () async {
      final items = [
        ShoppingItem(id: '1', text: 'Milk'),
        ShoppingItem(id: '2', text: 'Eggs', isInCart: true),
      ];
      
      await dbService.insertItems(items);
      final storedItems = await dbService.getItems();
      
      expect(storedItems.length, 2);
      expect(storedItems[0].text, 'Milk');
      expect(storedItems[0].isInCart, false);
      expect(storedItems[1].text, 'Eggs');
      expect(storedItems[1].isInCart, true);
    });

    test('clearItems works', () async {
      await dbService.insertItems([ShoppingItem(id: '1', text: 'Milk')]);
      await dbService.clearItems();
      final storedItems = await dbService.getItems();
      expect(storedItems.isEmpty, true);
    });

    test('updateItem works', () async {
      final item = ShoppingItem(id: '1', text: 'Milk');
      await dbService.insertItems([item]);
      
      final updated = ShoppingItem(id: '1', text: 'Milk', isInCart: true);
      await dbService.updateItem(updated);
      
      final storedItems = await dbService.getItems();
      expect(storedItems[0].isInCart, true);
    });
  });
}
