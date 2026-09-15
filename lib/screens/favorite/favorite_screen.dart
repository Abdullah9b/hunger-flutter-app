import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/favorite_service.dart';
import '../food/food_details_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteService = context.watch<FavoriteService>();
    final favorites = favoriteService.favorites;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF9),
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'No favorite foods yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final food = favorites[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: food.imageUrl.isNotEmpty
                            ? Image.network(food.imageUrl, fit: BoxFit.cover)
                            : const Icon(Icons.restaurant, size: 35),
                      ),
                    ),
                    title: Text(
                      food.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('৳${food.price.toStringAsFixed(0)}'),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Color(0xFF2F7D72),
                      ),
                      onPressed: () {
                        favoriteService.toggleFavorite(food);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailsScreen(food: food),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
