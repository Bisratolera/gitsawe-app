/// The Ge'ez / Amharic / English trio that appears on almost every verse.
class VerseText {
  final String geez;
  final String amharic;
  final String english;

  VerseText({
    required this.geez,
    required this.amharic,
    required this.english,
  });

  factory VerseText.fromJson(Map<String, dynamic> json) {
    return VerseText(
      geez: json['geez'] ?? '',
      amharic: json['amharic'] ?? '',
      english: json['english'] ?? '',
    );
  }
}

/// Where a verse comes from, e.g. "መዝሙረ ዳዊት 64:11-12"
class VerseReference {
  final String bookTitle;
  final String chapter;
  final String start;
  final String end;
  final String endText;

  VerseReference({
    required this.bookTitle,
    required this.chapter,
    required this.start,
    required this.end,
    this.endText = '',
  });

  factory VerseReference.fromJson(Map<String, dynamic> json) {
    return VerseReference(
      bookTitle: json['bookTitle'] ?? '',
      // chapter/start/end are sometimes int, sometimes String in your data
      chapter: json['chapter']?.toString() ?? '',
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      endText: json['endText']?.toString() ?? '',
    );
  }

  /// Renders as "64:11-12" or "64:11" if there's no end.
  String get display {
    if (end.isEmpty) return '$chapter:$start';
    return '$chapter:$start-$end';
  }
}

/// One verse entry: text + where it's from.
class Verse {
  final VerseText text;
  final VerseReference verse;

  Verse({required this.text, required this.verse});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      text: VerseText.fromJson(json['text'] ?? {}),
      verse: VerseReference.fromJson(json['verse'] ?? {}),
    );
  }

  /// Parses a field that is SOMETIMES a single object, SOMETIMES a list.
  /// Your seasonalGitsawe.json does this (firstDeacon is an object there,
  /// but a list in dailyGitsawe.json). This handles both safely.
  static List<Verse> listFromDynamic(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) {
        if (e is Map<String, dynamic>) return Verse.fromJson(e);
        if (e is String) {
          return Verse(
            text: VerseText(geez: '', amharic: e, english: ''),
            verse: VerseReference(bookTitle: '', chapter: '', start: '', end: ''),
          );
        }
        return null;
      }).whereType<Verse>().toList();
    }
    if (raw is Map<String, dynamic>) {
      return [Verse.fromJson(raw)];
    }
    if (raw is String) {
      return [
        Verse(
          text: VerseText(geez: '', amharic: raw, english: ''),
          verse: VerseReference(bookTitle: '', chapter: '', start: '', end: ''),
        )
      ];
    }
    return [];
  }
}