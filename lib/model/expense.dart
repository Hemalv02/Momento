import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter=DateFormat.yMd();
const uuid=Uuid();

enum Category{
  food,
  tShirt,
  music,
  venue,
  transport,
  gift,
  raffleDraw,
  decoration
}

final categoryIcons={
Category.food : Icons.lunch_dining_rounded,
Category.tShirt : Icons.checkroom,
Category.music : Icons.library_music,
Category.venue : Icons.add_location_rounded, // Venue instead of location
Category.transport : Icons.directions_bus,
Category.gift : Icons.redeem,
Category.raffleDraw : Icons.emoji_events,
Category.decoration : Icons.celebration,

};

class Expense {
  String title;
  double amount;
  String id;
  DateTime date;
  Category category;
  String get formattedDate {
    return formatter.format(date);
  }
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id=uuid.v4();
}
