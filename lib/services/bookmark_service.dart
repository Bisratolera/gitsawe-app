import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bookmark {
  final String date;
  final String title;

  const Bookmark({required this.date, required this.title});

  Map<String, dynamic> toJson() => {'date': date, 'title': title};

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      date: json['date'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }
}

class BookmarkService extends ChangeNotifier {
  BookmarkService._();

  static final BookmarkService instance = BookmarkService._();
  static const _key = 'bookmarks';

  List<Bookmark> _bookmarks = [];
  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final loaded = <Bookmark>[];
    for (final value in raw) {
      try {
        loaded.add(Bookmark.fromJson(jsonDecode(value) as Map<String, dynamic>));
      } catch (e) {
        debugPrint('BookmarkService: skipping unreadable bookmark: $e');
      }
    }
    _bookmarks = loaded;
  }

  bool contains(String date, String title) {
    return _bookmarks.any((bookmark) => bookmark.date == date && bookmark.title == title);
  }

  Future<void> toggle(Bookmark bookmark) async {
    if (contains(bookmark.date, bookmark.title)) {
      _bookmarks.removeWhere(
        (item) => item.date == bookmark.date && item.title == bookmark.title,
      );
    } else {
      _bookmarks = [bookmark, ..._bookmarks];
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _bookmarks.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}