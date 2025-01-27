import 'package:flutter/material.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/food/food_model.dart';
import 'package:momento/screens/events/food/food_service.dart';

class FoodBottomSheet extends StatefulWidget {
  final int eventId;
  final Food? food;
  final FoodService foodService;
  final String userId = prefs.getString('userId')!;

  FoodBottomSheet({
    super.key,
    required this.eventId,
    this.food,
    required this.foodService,
  });

  @override
  State<FoodBottomSheet> createState() => _FoodBottomSheetState();
}

class _FoodBottomSheetState extends State<FoodBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _servingSizeController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  String _selectedFoodType = 'Breakfast';
  String _selectedDietaryInfo = 'Regular';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.food?.foodName);
    _servingSizeController =
        TextEditingController(text: widget.food?.servingSize.toString());
    _priceController =
        TextEditingController(text: widget.food?.pricePerServing.toString());
    _descriptionController =
        TextEditingController(text: widget.food?.description);
    if (widget.food != null) {
      _selectedFoodType = widget.food!.foodType;
      _selectedDietaryInfo = widget.food!.dietaryInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFF003675);

    // This ensures the bottom sheet is not covered by the keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: bottomPadding + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text(
              widget.food == null ? 'Add New Food' : 'Edit Food',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: baseColor,
              ),
            ),
            const SizedBox(height: 24),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Food Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.restaurant_menu),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Meal Type
                  DropdownButtonFormField<String>(
                    value: _selectedFoodType,
                    decoration: InputDecoration(
                      labelText: 'Meal Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                    items: ['Breakfast', 'Lunch', 'Dinner']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedFoodType = value!),
                  ),
                  const SizedBox(height: 16),

                  // Serving Size
                  TextFormField(
                    controller: _servingSizeController,
                    decoration: InputDecoration(
                      labelText: 'Serving Size',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Price per Serving
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price per Serving',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Dietary Info
                  DropdownButtonFormField<String>(
                    value: _selectedDietaryInfo,
                    decoration: InputDecoration(
                      labelText: 'Dietary Info',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.info_outline),
                    ),
                    items: ['Regular', 'Vegetarian', 'Vegan', 'Halal']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedDietaryInfo = value!),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveFood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: baseColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save'),
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

  void _saveFood() async {
    if (_formKey.currentState?.validate() ?? false) {
      print(widget.userId);
      final food = Food(
        id: widget.food?.id,
        eventId: widget.eventId,
        foodName: _nameController.text,
        foodType: _selectedFoodType,
        servingSize: int.parse(_servingSizeController.text),
        dietaryInfo: _selectedDietaryInfo,
        pricePerServing: double.parse(_priceController.text),
        description: _descriptionController.text,
        createdAt: widget.food?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.userId,
      );

      try {
        if (widget.food == null) {
          await widget.foodService.addFood(food);
        } else {
          await widget.foodService.updateFood(food);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
        
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingSizeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
