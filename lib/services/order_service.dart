import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder({
    required String userId,
    required List<CartItem> items,
    required double totalPrice,
    required String paymentMethod,
  }) async {
    await _firestore.collection('orders').add({
      'userId': userId,
      'items': items.map((item) {
        return {
          'foodId': item.food.id,
          'name': item.food.name,
          'price': item.food.price,
          'quantity': item.quantity,
          'totalPrice': item.totalPrice,
        };
      }).toList(),
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
