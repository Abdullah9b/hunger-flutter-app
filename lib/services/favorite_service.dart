import 'package:flutter/foundation.dart';

import '../models/food.dart';

class FavoriteService extends ChangeNotifier {
  final List<Food> _favorites = [];

  List<Food> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String foodId) {
    return _favorites.any((food) => food.id == foodId);
  }

  void toggleFavorite(Food food) {
    if (isFavorite(food.id)) {
      _favorites.removeWhere((item) => item.id == food.id);
    } else {
      _favorites.add(food);
    }

    notifyListeners();
  }
}
