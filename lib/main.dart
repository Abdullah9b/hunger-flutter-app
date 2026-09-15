import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/profile/profile_screen.dart';
import 'firebase_options.dart';
import 'models/food.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/food/food_details_screen.dart';
import 'services/food_service.dart';

import 'package:provider/provider.dart';

import 'services/cart_service.dart';
import 'services/favorite_service.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/favorite/favorite_screen.dart';
import 'screens/notifications/notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => FavoriteService()),
      ],
      child: const HungerApp(),
    ),
  );
}

class HungerApp extends StatelessWidget {
  const HungerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hunger',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAF9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7D72)),
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}

class HungerHomePage extends StatefulWidget {
  const HungerHomePage({super.key});

  @override
  State<HungerHomePage> createState() => _HungerHomePageState();
}

class _HungerHomePageState extends State<HungerHomePage> {
  int _selectedIndex = 0;
  int _selectedCategory = 0;

  final Color primaryColor = const Color(0xFF2F7D72);

  final List<String> categories = ['All', 'Breakfast', 'Lunch', 'Dinner'];

  final FoodService _foodService = FoodService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? _buildHomePage()
          : _selectedIndex == 1
          ? const FavoriteScreen()
          : _selectedIndex == 2
          ? const CartScreen()
          : _selectedIndex == 3
          ? const OrdersScreen()
          : const ProfileScreen(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return StreamBuilder<List<Food>>(
      stream: _foodService.getFoods(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Error loading foods:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final foods = snapshot.data ?? [];

        List<Food> filteredFoods;

        if (_selectedCategory == 0) {
          filteredFoods = foods;
        } else {
          final selectedName = categories[_selectedCategory].toLowerCase();

          filteredFoods = foods
              .where((food) => food.category.toLowerCase() == selectedName)
              .toList();
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'What are you\ncooking today?',
                        style: TextStyle(
                          fontSize: 32,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 29,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 12,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search any recipes',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA4A5),
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF8F999A),
                        size: 27,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  height: 190,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 20, 10, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Cook the best\nrecipes at home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  height: 1.25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryColor,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Explore',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800',
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: primaryColor,
                              child: const Icon(
                                Icons.restaurant,
                                color: Colors.white,
                                size: 70,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 58,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategory == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = index;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            right: index == categories.length - 1 ? 0 : 12,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              if (!isSelected)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF7B8586),
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick & Easy',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'View all',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (filteredFoods.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'No meals available',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredFoods.length > 4
                        ? 4
                        : filteredFoods.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.65,
                        ),
                    itemBuilder: (context, index) {
                      return _buildMealCard(filteredFoods[index]);
                    },
                  ),
                const SizedBox(height: 25),
                const Text(
                  "Chef's Recommendations",
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildRecommendationCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealCard(Food food) {
    final hasImage = food.imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailsScreen(food: food),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 125,
                  width: double.infinity,
                  child: hasImage
                      ? Image.network(
                          food.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFoodPlaceholder();
                          },
                        )
                      : _buildFoodPlaceholder(),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<FavoriteService>(
                    builder: (context, favoriteService, child) {
                      final isFavorite = favoriteService.isFavorite(food.id);

                      return Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            favoriteService.toggleFavorite(food);
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? const Color(0xFF2F7D72)
                                : const Color(0xFF687172),
                            size: 19,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        size: 15,
                        color: Color(0xFF9AA3A4),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          food.category,
                          style: const TextStyle(
                            color: Color(0xFF9AA3A4),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF9AA3A4),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        '20 Min',
                        style: TextStyle(
                          color: Color(0xFF9AA3A4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '৳${food.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3F1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '+ Add',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodPlaceholder() {
    return Container(
      color: const Color(0xFFE8EFED),
      child: Icon(Icons.restaurant, size: 50, color: primaryColor),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: double.infinity,
            child: Image.network(
              'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=600',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE8EFED),
                  child: Icon(Icons.restaurant, color: primaryColor, size: 45),
                );
              },
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Healthy Green Bowl',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Fresh ingredients • 20 Min',
                    style: TextStyle(color: Color(0xFF8C9697), fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '৳350',
                    style: TextStyle(
                      color: Color(0xFF2F7D72),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
