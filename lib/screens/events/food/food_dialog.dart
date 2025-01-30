import 'package:flutter/material.dart';
import 'package:momento/main.dart';
import 'package:momento/screens/events/food/food_model.dart';
import 'package:momento/screens/events/food/food_service.dart';

class FoodDialog extends StatefulWidget {
  final int eventId;
  final Food? food;
  final FoodService foodService;

  const FoodDialog({
    super.key,
    required this.eventId,
    this.food,
    required this.foodService,
  });

  @override
  State<FoodDialog> createState() => _FoodDialogState();
}

class _FoodDialogState extends State<FoodDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _servingSizeController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  String _selectedFoodType = 'Breakfast';
  String _selectedDietaryInfo = 'Regular';
  final String userId = prefs.getString('userId')!;

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
    return AlertDialog(
      title: Text(widget.food == null ? 'Add Food' : 'Edit Food'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedFoodType,
                items: ['Breakfast', 'Lunch', 'Dinner']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedFoodType = value!),
                decoration: const InputDecoration(labelText: 'Meal Type'),
              ),
              TextFormField(
                controller: _servingSizeController,
                decoration: const InputDecoration(labelText: 'Serving Size'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration:
                    const InputDecoration(labelText: 'Price per Serving'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedDietaryInfo,
                items: ['Regular', 'Vegetarian', 'Vegan', 'Halal']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedDietaryInfo = value!),
                decoration: const InputDecoration(labelText: 'Dietary Info'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveFood,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveFood() async {
    if (_formKey.currentState?.validate() ?? false) {
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
        createdBy: userId,
      );

      try {
        if (widget.food == null) {
          await widget.foodService.addFood(food);
        } else {
          await widget.foodService.updateFood(food);
        }
        Navigator.pop(context);
      } catch (e) {
        if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );}
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
