import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/food.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  double get totalPrice {
    return _items.fold(0, (total, item) => total + item.totalPrice);
  }

  void addToCart(Food food) {
    final index = _items.indexWhere((item) => item.food.id == food.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(food: food));
    }

    notifyListeners();
  }

  void increaseQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.food.id == foodId);

    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.food.id == foodId);

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  void removeFromCart(String foodId) {
    _items.removeWhere((item) => item.food.id == foodId);

    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
