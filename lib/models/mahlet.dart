import 'dart:convert';

/// A mahlet (ማህሌት) is a liturgical order or hymn sequence.
class Mahlet {
  final String title;
  final String? source;
  final List<MahletDetail> details;

  Mahlet({
    required this.title,
    this.source,
    required this.details,
  });

  factory Mahlet.fromJson(Map<String, dynamic> json) {
    return Mahlet(
      title: json['title'] ?? '',
      source: json['source'],
      details: ((json['detail'] as List<dynamic>?) ?? [])
          .map((d) => MahletDetail.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'source': source,
      'detail': details.map((d) => d.toJson()).toList(),
    };
  }
}

class MahletDetail {
  final String key;
  final String verse;

  MahletDetail({
    required this.key,
    required this.verse,
  });

  factory MahletDetail.fromJson(Map<String, dynamic> json) {
    return MahletDetail(
      key: json['key'] ?? '',
      verse: json['verse'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'verse': verse,
    };
  }
}

/// Helper function to parse a JSON string containing an array of Mahlets.
List<Mahlet> parseMahletList(String jsonString) {
  final parsed = jsonDecode(jsonString);
  
  if (parsed is List) {
    return parsed
        .map((jsonItem) => Mahlet.fromJson(jsonItem as Map<String, dynamic>))
        .toList();
  }
  
  return [];
}
