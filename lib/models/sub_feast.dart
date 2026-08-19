// lib/models/sub_feast.dart
class SubFeast {
  final String name;
  final String amharicName;
  final String key;
  final String feast; // foreign key -> Feast.key

  SubFeast({
    required this.name,
    required this.amharicName,
    required this.key,
    required this.feast,
  });

  factory SubFeast.fromJson(Map<String, dynamic> json) => SubFeast(
        name: json['name'] ?? '',
        amharicName: json['amharicName'] ?? '',
        key: json['key'] ?? '',
        feast: json['feast'] ?? '',
      );
}