import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/sinksar.dart';

class SinksarService {
  static final SinksarService instance = SinksarService._internal();
  SinksarService._internal();

  SinksarManifest? manifest;
  final Map<int, SinksarMonth> _cache = {};

  Future<void> loadManifest() async {
    if (manifest != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/sinksar/manifest.json');
      manifest = SinksarManifest.fromJson(json.decode(jsonStr));
    } catch (e) {
      print('Error loading Sinksar manifest: $e');
    }
  }

  Future<SinksarMonth?> loadSinksarMonth(int month) async {
    if (_cache.containsKey(month)) return _cache[month];
    
    try {
      final jsonStr = await rootBundle.loadString('assets/data/sinksar/$month.json');
      final m = SinksarMonth.fromJson(json.decode(jsonStr));
      _cache[month] = m;
      return m;
    } catch (e) {
      print('Error loading Sinksar data for month $month: $e');
      return null;
    }
  }

  Future<List<SinksarEntry>> loadSinksarDay(int month, int day) async {
    final m = await loadSinksarMonth(month);
    if (m == null) return [];
    
    try {
      final d = m.days.firstWhere((element) => element.day == day);
      return d.entries;
    } catch (e) {
      return [];
    }
  }

  String sinksarMonthName(int month) {
    if (manifest == null) return month.toString();
    try {
      return manifest!.months.firstWhere((m) => m.month == month).name;
    } catch (e) {
      return month.toString();
    }
  }
}
