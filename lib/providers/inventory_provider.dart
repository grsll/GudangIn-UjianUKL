import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';

class InventoryProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  InventoryProvider(this._firestoreService);

  // Expose stream
  Stream<List<ItemModel>> get itemsStream => _firestoreService.getItemsStream();

  // Add Item Wrapper
  Future<void> addItem(ItemModel item) async {
    await _firestoreService.addItem(item);
    notifyListeners();
  }

  // Update Item Wrapper
  Future<void> updateItem(ItemModel item) async {
    await _firestoreService.updateItem(item);
    notifyListeners();
  }

  // Delete Item Wrapper
  Future<void> deleteItem(String id) async {
    await _firestoreService.deleteItem(id);
    notifyListeners();
  }
}
