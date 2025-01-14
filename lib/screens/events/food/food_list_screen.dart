import 'package:flutter/material.dart';
import 'package:momento/screens/events/food/food_bottom_sheet.dart';
import 'package:momento/screens/events/food/food_dialog.dart';
import 'package:momento/screens/events/food/food_model.dart';
import 'package:momento/screens/events/food/food_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodListScreen extends StatefulWidget {
  final int eventId;

  const FoodListScreen({super.key, required this.eventId});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final FoodService _foodService = FoodService(Supabase.instance.client);
  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food List'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showFoodDialog(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Food>>(
        stream: _foodService.streamFoods(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final foods = snapshot.data!;

          return DefaultTabController(
            length: mealTypes.length,
            child: Column(
              children: [
                TabBar(
                  tabs: mealTypes.map((type) => Tab(text: type)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: mealTypes.map((mealType) {
                      final mealFoods = foods
                          .where((food) => food.foodType == mealType)
                          .toList();
                      return _buildFoodList(mealFoods);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodList(List<Food> foods) {
    if (foods.isEmpty) {
      return _buildEmptyState();
    }

    final baseColor = const Color(0xFF003675);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return Dismissible(
          key: Key(food.id.toString()),
          onDismissed: (_) => _foodService.deleteFood(food.id!),
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    baseColor.withOpacity(0.05),
                    baseColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.foodName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: baseColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 16,
                                color: baseColor.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${food.servingSize} servings',
                                style: TextStyle(
                                  color: baseColor.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: baseColor.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                food.dietaryInfo,
                                style: TextStyle(
                                  color: baseColor.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: 16,
                                color: baseColor.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${food.pricePerServing.toStringAsFixed(2)} per serving',
                                style: TextStyle(
                                  color: baseColor.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          if (food.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              food.description,
                              style: TextStyle(
                                color: baseColor.withOpacity(0.6),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showFoodDialog(context, food: food),
                          color: baseColor.withOpacity(0.6),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            food.foodType,
                            style: TextStyle(
                              fontSize: 12,
                              color: baseColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Optional: Update the empty state to match the new color scheme
  Widget _buildEmptyState() {
    final baseColor = const Color(0xFF003675);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: baseColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Food Items Yet',
                style: TextStyle(
                  fontSize: 20,
                  color: baseColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the + button to add your first food item',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: baseColor.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Add this helper method to get colors for meal types
  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

// Update the empty state with a more polished design
// Widget _buildEmptyState() {
//   return TweenAnimationBuilder(
//     tween: Tween<double>(begin: 0, end: 1),
//     duration: const Duration(milliseconds: 800),
//     builder: (context, double value, child) {
//       return Opacity(
//         opacity: value,
//         child: Transform.translate(
//           offset: Offset(0, 20 * (1 - value)),
//           child: child,
//         ),
//       );
//     },
//     child: Center(
//       child: Container(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.restaurant_menu,
//                 size: 64,
//                 color: Colors.grey[400],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No Food Items Yet',
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Colors.grey[800],
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Tap the + button to add your first food item',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 height: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

  // Widget _buildFoodList(List<Food> foods) {
  //   if (foods.isEmpty) {
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.no_food, // or Icons.restaurant_menu
  //             size: 64,
  //             color: Colors.grey[400],
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             'No food available',
  //             style: TextStyle(
  //               fontSize: 18,
  //               color: Colors.grey[600],
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Tap the + button to add food',
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: Colors.grey[500],
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   return ListView.builder(
  //     itemCount: foods.length,
  //     itemBuilder: (context, index) {
  //       final food = foods[index];
  //       return Dismissible(
  //         key: Key(food.id.toString()),
  //         onDismissed: (_) => _foodService.deleteFood(food.id!),
  //         background: Container(
  //           color: Colors.red,
  //           alignment: Alignment.centerRight,
  //           padding: const EdgeInsets.only(right: 16),
  //           child: const Icon(Icons.delete, color: Colors.white),
  //         ),
  //         child: ListTile(
  //           title: Text(food.foodName),
  //           subtitle: Text(
  //             '${food.servingSize} servings - ${food.dietaryInfo}\n\$${food.pricePerServing.toStringAsFixed(2)} per serving',
  //           ),
  //           trailing: IconButton(
  //             icon: const Icon(Icons.edit),
  //             onPressed: () => _showFoodDialog(context, food: food),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showFoodDialog(BuildContext context, {Food? food}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This allows the bottom sheet to be full height
      backgroundColor: Colors.transparent,
      builder: (context) => FoodBottomSheet(
        eventId: widget.eventId,
        food: food,
        foodService: _foodService,
      ),
    );
  }
}
