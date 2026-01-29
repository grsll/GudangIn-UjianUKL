import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final CollectionReference _itemsCollection = FirebaseFirestore.instance
      .collection('items');

  // Add Item
  Future<void> addItem(ItemModel item) async {
    try {
      // Create a doc with auto-ID but we don't need to put ID in data yet if we use the doc ID
      // But ItemModel has ID.
      // Usually we let Firestore generate ID.
      DocumentReference docRef = _itemsCollection.doc();

      // Update the item ID locally before saving
      // Actually ItemModel is immutable, we should probably just pass data without ID
      // Or create ItemModel with empty ID and then use docRef.id

      // Let's pass the data derived from the model but replace ID where needed or just ignore it in toMap
      await docRef.set(item.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Update Item
  Future<void> updateItem(ItemModel item) async {
    try {
      await _itemsCollection.doc(item.id).update(item.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete Item
  Future<void> deleteItem(String id) async {
    try {
      await _itemsCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get Items Stream
  Stream<List<ItemModel>> getItemsStream() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ItemModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // Get Single Item
  Future<ItemModel?> getItem(String id) async {
    try {
      DocumentSnapshot doc = await _itemsCollection.doc(id).get();
      if (doc.exists) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
