// lib/models/feast.dart
class Feast {
  final String name;
  final String amharicName;
  final String key;
  final String? date; // "DD-MM", optional — some feasts don't have a fixed date
  final String month;

  Feast({
    required this.name,
    required this.amharicName,
    required this.key,
    this.date,
    required this.month,
  });

  factory Feast.fromJson(Map<String, dynamic> json) => Feast(
        name: json['name'] ?? '',
        amharicName: json['amharicName'] ?? '',
        key: json['key'] ?? '',
        date: json['date'],
        month: json['month'] ?? '',
      );
}