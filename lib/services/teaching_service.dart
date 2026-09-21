import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/appostles.dart';

class TeachingDocument {
  final String id;
  final String title;
  final List<Section> sections;

  const TeachingDocument({
    required this.id,
    required this.title,
    required this.sections,
  });

  factory TeachingDocument.fromAsset(String assetPath, Map<String, dynamic> json) {
    final appostles = Appostles.fromJson(json);
    return TeachingDocument(
      id: assetPath,
      title: appostles.title.isNotEmpty ? appostles.title : 'ትምህርት',
      sections: appostles.sections,
    );
  }
}

class TeachingService {
  TeachingService._internal();
  static final TeachingService instance = TeachingService._internal();

  static const List<String> _assetPaths = [
    'assets/data/መላእክት.json',
    'assets/data/ቅዱሳን_ሐዋርያት.json',
    'assets/data/ቅዳሴ.json',
    'assets/data/ዓመታዊ_እና_ወርሃዊ_መታሰቢያ_በዓላት.json',
  ];

  bool _loaded = false;
  final List<TeachingDocument> _documents = [];

  List<TeachingDocument> get documents => _loaded ? List.unmodifiable(_documents) : const [];

  Future<void> load() async {
    if (_loaded) return;

    final contents = await Future.wait(
      _assetPaths.map((path) async {
        final raw = await rootBundle.loadString(path);
        final decoded = jsonDecode(raw);
        return TeachingDocument.fromAsset(path, decoded as Map<String, dynamic>);
      }),
    );

    _documents.addAll(contents.where((doc) => doc.title.trim().isNotEmpty));
    _loaded = true;
  }
}
