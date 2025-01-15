class Food {
  final int? id;
  final int eventId;
  final String foodName;
  final String foodType;
  final int servingSize;
  final String dietaryInfo;
  final double pricePerServing;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Food({
    this.id,
    required this.eventId,
    required this.foodName,
    required this.foodType,
    required this.servingSize,
    required this.dietaryInfo,
    required this.pricePerServing,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      eventId: json['event_id'],
      foodName: json['food_name'],
      foodType: json['food_type'],
      servingSize: json['serving_size'],
      dietaryInfo: json['dietary_info'],
      pricePerServing: json['price_per_serving'].toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'food_name': foodName,
      'food_type': foodType,
      'serving_size': servingSize,
      'dietary_info': dietaryInfo,
      'price_per_serving': pricePerServing,
      'description': description,
      'created_by': createdBy,
    };
  }
}
