import 'package:momento/screens/events/food/food_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodService {
  final SupabaseClient _supabase;

  FoodService(this._supabase);

  Stream<List<Food>> streamFoods(int eventId) {
    return _supabase
        .from('food')
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .map((data) => data.map((json) => Food.fromJson(json)).toList());
  }

  Future<void> addFood(Food food) async {
    await _supabase.from('food').insert(food.toJson());
  }

  Future<void> updateFood(Food food) async {
    await _supabase
        .from('food')
        .update(food.toJson())
        .eq('id', food.id as Object);
  }

  Future<void> deleteFood(int foodId) async {
    await _supabase.from('food').delete().eq('id', foodId);
  }
}
