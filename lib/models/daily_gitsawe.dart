import 'verse.dart';

class SnksarEntry {
  final String amharic;
  SnksarEntry({required this.amharic});
  factory SnksarEntry.fromJson(Map<String, dynamic> json) =>
      SnksarEntry(amharic: json['amharic'] ?? '');
}

/// The "ንባባት ነግህ" (morning readings) block.
class ReadingGroup {
  final List<Verse> msbak;
  final List<Verse> wengel;
  final List<Verse> firstDeacon;
  final List<Verse> secondDeacon;
  final List<Verse> secondKahn;
  final List<Verse> kidassie; // only present in the "kidassie" group

  ReadingGroup({
    this.msbak = const [],
    this.wengel = const [],
    this.firstDeacon = const [],
    this.secondDeacon = const [],
    this.secondKahn = const [],
    this.kidassie = const [],
  });

  factory ReadingGroup.fromJson(Map<String, dynamic> json) {
    return ReadingGroup(
      msbak: Verse.listFromDynamic(json['msbak']),
      wengel: Verse.listFromDynamic(json['wengel']),
      firstDeacon: Verse.listFromDynamic(json['firstDeacon']),
      secondDeacon: Verse.listFromDynamic(json['secondDeacon']),
      secondKahn: Verse.listFromDynamic(json['secondKahn']),
      kidassie: Verse.listFromDynamic(json['kidassie']),
    );
  }

  bool get isEmpty =>
      msbak.isEmpty &&
      wengel.isEmpty &&
      firstDeacon.isEmpty &&
      secondDeacon.isEmpty &&
      secondKahn.isEmpty &&
      kidassie.isEmpty;
}

class DailyGitsawe {
  final String date; // "DD-MM" in the Ethiopian calendar
  final String title;
  final List<SnksarEntry> snksar;
  final ReadingGroup negh;
  final ReadingGroup kidassie;

  DailyGitsawe({
    required this.date,
    required this.title,
    required this.snksar,
    required this.negh,
    required this.kidassie,
  });

  factory DailyGitsawe.fromJson(Map<String, dynamic> json) {
    return DailyGitsawe(
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      snksar: (json['snksar'] as List<dynamic>? ?? [])
          .map((e) => SnksarEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      negh: ReadingGroup.fromJson(json['negh'] ?? {}),
      kidassie: ReadingGroup.fromJson(json['kidassie'] ?? {}),
    );
  }
}