/// One playable file, derived from a single scraped source entry.
class AudioTrack {
  final String id;
  final String title;
  final String url;      // full https URL — streamed directly, never downloaded
  final String folderId;

  AudioTrack({
    required this.id,
    required this.title,
    required this.url,
    required this.folderId,
  });
}

/// A folder is really just "everything that shares the same URL path
/// minus the filename" — there's no folder object in the raw scrape,
/// we build these ourselves while parsing.
class AudioFolder {
  final String id;          // stable hash of the path, see AudioLibraryService
  final List<String> path;  // e.g. ['kine_bet', '1 ሰዋስወ ግእዝ', '0 መግቢያ']
  final String categoryKey; // path[0]
  final String title;       // last path segment — the immediate folder name
  int trackCount;

  AudioFolder({
    required this.id,
    required this.path,
    required this.categoryKey,
    required this.title,
    this.trackCount = 0,
  });
}

class AudioCategory {
  final String key;
  final String name;
  final String amharicName;
  final String description;
  final int order;

  AudioCategory({
    required this.key,
    required this.name,
    required this.amharicName,
    required this.description,
    required this.order,
  });

  factory AudioCategory.fromJson(Map<String, dynamic> json) => AudioCategory(
        key: json['key'] ?? '',
        name: json['name'] ?? '',
        amharicName: json['amharicName'] ?? '',
        description: json['description'] ?? '',
        order: json['order'] ?? 99,
      );

  /// Used when a folder's category key isn't in audioCategories.json —
  /// keeps the UI working instead of crashing on unknown categories.
  factory AudioCategory.fallback(String key) => AudioCategory(
        key: key,
        name: key,
        amharicName: key,
        description: '',
        order: 99,
      );
}

class AudioCategoryGroup {
  final AudioCategory category;
  final List<AudioFolder> folders;
  final int trackCount;

  AudioCategoryGroup({
    required this.category,
    required this.folders,
    required this.trackCount,
  });
}

/// The whole parsed archive, held in memory once per app run.
class AudioLibrary {
  final List<AudioFolder> folders;
  final List<AudioTrack> tracks;
  final Map<String, List<AudioTrack>> byFolder;
  final Map<String, AudioFolder> folderById;
  final List<AudioCategoryGroup> categories;

  AudioLibrary({
    required this.folders,
    required this.tracks,
    required this.byFolder,
    required this.folderById,
    required this.categories,
  });
}