import '../model/database_helper.dart';
import '../model/item.dart';

class ItemController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Item>> fetchItems() async {
    return await _dbHelper.getItems();
  }

  Future<void> addItem(String name, int quantity) async {
    final newItem = Item(name: name, quantity: quantity);
    await _dbHelper.insertItem(newItem);
  }

  Future<void> updateItem(Item item) async {
    await _dbHelper.updateItem(item); // Implementação em `DatabaseHelper`
  }

  Future<void> deleteItem(int id) async {
    await _dbHelper.deleteItem(id); // Implementação em `DatabaseHelper`
  }
}
