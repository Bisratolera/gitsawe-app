// lib/models/month.dart
class GitsaweMonth {
  final String name;
  final String amharicName;
  final String key;

  GitsaweMonth({required this.name, required this.amharicName, required this.key});

  factory GitsaweMonth.fromJson(Map<String, dynamic> json) => GitsaweMonth(
        name: json['name'] ?? '',
        amharicName: json['amharicName'] ?? '',
        key: json['key'] ?? '',
      );
}