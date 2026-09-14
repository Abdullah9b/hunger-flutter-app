import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Food>> getFoods() {
    return _firestore.collection('foods').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Food.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addFood(Food food) async {
    await _firestore.collection('foods').add(food.toMap());
  }

  Future<void> deleteFood(String foodId) async {
    await _firestore.collection('foods').doc(foodId).delete();
  }
}
