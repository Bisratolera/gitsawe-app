class SinksarEntry {
  final String title;
  final String text;

  SinksarEntry({required this.title, required this.text});

  factory SinksarEntry.fromJson(Map<String, dynamic> json) {
    return SinksarEntry(
      title: json['title'] ?? '',
      text: json['text'] ?? '',
    );
  }
}

class SinksarDay {
  final int day;
  final List<SinksarEntry> entries;

  SinksarDay({required this.day, required this.entries});

  factory SinksarDay.fromJson(Map<String, dynamic> json) {
    return SinksarDay(
      day: json['day'],
      entries: (json['entries'] as List)
          .map((e) => SinksarEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SinksarMonth {
  final int month;
  final List<SinksarDay> days;

  SinksarMonth({required this.month, required this.days});

  factory SinksarMonth.fromJson(Map<String, dynamic> json) {
    return SinksarMonth(
      month: json['month'],
      days: (json['days'] as List)
          .map((e) => SinksarDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SinksarManifestMonth {
  final int month;
  final String name;
  final int days;

  SinksarManifestMonth({
    required this.month,
    required this.name,
    required this.days,
  });

  factory SinksarManifestMonth.fromJson(Map<String, dynamic> json) {
    return SinksarManifestMonth(
      month: json['month'],
      name: json['name'],
      days: json['days'],
    );
  }
}

class SinksarManifest {
  final int contentVersion;
  final List<SinksarManifestMonth> months;

  SinksarManifest({required this.contentVersion, required this.months});

  factory SinksarManifest.fromJson(Map<String, dynamic> json) {
    return SinksarManifest(
      contentVersion: json['contentVersion'],
      months: (json['months'] as List)
          .map((e) => SinksarManifestMonth.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
