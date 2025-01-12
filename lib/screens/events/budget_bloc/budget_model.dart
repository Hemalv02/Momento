enum TransactionType { income, expense }

enum TransactionCategory { food, gift, transport, entertainment, bills, others }

class Transaction {
  final int id;
  final int eventId;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory? category;
  final String description;
  final DateTime date;
  final String createdBy;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.eventId,
    required this.title,
    required this.amount,
    required this.type,
    this.category,
    required this.description,
    required this.date,
    required this.createdBy,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      eventId: json['event_id'],
      title: json['title'],
      amount: json['amount'] is String
          ? double.parse(json['amount'])
          : json['amount'],
      type: TransactionType.values
          .firstWhere((e) => e.toString().split('.').last == json['type']),
      category: json['category'] != null
          ? TransactionCategory.values.firstWhere(
              (e) => e.toString().split('.').last == json['category'])
          : null,
      description: json['description'],
      date: DateTime.parse(json['date']),
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'title': title,
      'amount': amount,
      'type': type.toString().split('.').last,
      'category': category?.toString().split('.').last,
      'description': description,
      'date': date.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
