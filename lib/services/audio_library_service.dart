import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/audio.dart';

class AudioLibraryService {
  AudioLibraryService._internal();
  static final AudioLibraryService instance = AudioLibraryService._internal();

  AudioLibrary? _library;
  Map<String, String> _bookMap = {};
  Map<String, String> _kidassieMap = {};

  bool get isLoaded => _library != null;
  AudioLibrary get library {
    final lib = _library;
    if (lib == null) {
      throw StateError('AudioLibraryService.load() must complete before use.');
    }
    return lib;
  }

  /// Parses assets/data/audio.json (the RAW scraper export — a list of
  /// {id, url, title, ...} sources) into folders + tracks, grouped by
  /// URL path. Safe to call more than once — only loads once.
  Future<AudioLibrary> load() async {
    final cached = _library;
    if (cached != null) return cached;

    final results = await Future.wait([
      rootBundle.loadString('assets/data/audio.json'),
      rootBundle.loadString('assets/data/audioCategories.json'),
      rootBundle.loadString('assets/data/audioBooks.json'),
      rootBundle.loadString('assets/data/audioKidassie.json'),
    ]);

    final raw = jsonDecode(results[0]) as Map<String, dynamic>;
    final categoriesRaw = jsonDecode(results[1]) as List<dynamic>;
    _bookMap = Map<String, String>.from(jsonDecode(results[2]));
    _kidassieMap = Map<String, String>.from(jsonDecode(results[3]));

    final categories = categoriesRaw
        .map((c) => AudioCategory.fromJson(c as Map<String, dynamic>))
        .toList();
    final categoryByKey = {for (final c in categories) c.key: c};

    final extractions = raw['extractions'] as List<dynamic>;
    final sources = extractions
        .expand((e) => (e as Map<String, dynamic>)['sources'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final tracks = <AudioTrack>[];
    final folders = <String, AudioFolder>{}; // keyed by folder id
    final byFolder = <String, List<AudioTrack>>{};

    for (final s in sources) {
      final url = s['url'] as String? ?? '';
      if (url.isEmpty) continue;

      final uri = Uri.tryParse(url);
      if (uri == null) continue;

      // Path segments, URL-decoded: ['kine_bet', '1 ሰዋስወ ግእዝ', '0 መግቢያ', '1 መግለጫ.mp3']
      final segments = uri.pathSegments;
      if (segments.length < 2) continue; // need at least category + filename
      final folderPath = segments.sublist(0, segments.length - 1);
      final folderId = _stableId(folderPath.join('/'));

      folders.putIfAbsent(
        folderId,
        () => AudioFolder(
          id: folderId,
          path: folderPath,
          categoryKey: folderPath.first,
          title: folderPath.last,
        ),
      );
      folders[folderId]!.trackCount += 1;

      final track = AudioTrack(
        id: s['id'] as String? ?? folderId,
        title: s['title'] as String? ?? segments.last,
        url: url,
        folderId: folderId,
      );
      tracks.add(track);
      byFolder.putIfAbsent(folderId, () => []).add(track);
    }

    // Group folders into categories, sorted by the category's declared order.
    final byCategoryKey = <String, List<AudioFolder>>{};
    for (final f in folders.values) {
      byCategoryKey.putIfAbsent(f.categoryKey, () => []).add(f);
    }
    final categoryGroups = byCategoryKey.entries.map((e) {
      final cat = categoryByKey[e.key] ?? AudioCategory.fallback(e.key);
      final count = e.value.fold<int>(0, (a, f) => a + f.trackCount);
      return AudioCategoryGroup(category: cat, folders: e.value, trackCount: count);
    }).toList()
      ..sort((a, b) => a.category.order.compareTo(b.category.order));

    final lib = AudioLibrary(
      folders: folders.values.toList(),
      tracks: tracks,
      byFolder: byFolder,
      folderById: folders,
      categories: categoryGroups,
    );
    _library = lib;
    return lib;
  }

  /// Deterministic short id for a folder path, so the same folder always
  /// gets the same id across app runs (needed so bookmarks/deep-links
  /// to a folder keep working).
  String _stableId(String folderPath) {
    final digest = sha1.convert(utf8.encode(folderPath));
    return 'f_${digest.toString().substring(0, 10)}';
  }

  List<AudioTrack> tracksOfFolder(String folderId) =>
      library.byFolder[folderId] ?? const [];

  /// Simple substring search over every track title. This is the part
  /// that works reliably today without needing the (currently unusable)
  /// audioBooks.json / audioKidassie.json mapping files.
  List<AudioTrack> searchTracks(String query, {int limit = 60}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final out = <AudioTrack>[];
    for (final t in library.tracks) {
      if (t.title.toLowerCase().contains(q)) {
        out.add(t);
        if (out.length >= limit) break;
      }
    }
    return out;
  }

  String normalizeBook(String s) =>
      s.replaceAll(RegExp(r'\s+'), "").replaceAll("ኛ", "").replaceAll("መልዕክት", "መልእክት");

  /// Tries to find the best-match audio track for a reading.
  AudioTrack? findReadingTrack(String? bookTitle, dynamic chapter) {
    if (bookTitle == null || !isLoaded) return null;
    
    // 1. Normalize and map book title to a potential folder identifier
    final normalized = normalizeBook(bookTitle);
    
    // 2. Look for folders whose titles or paths contain clues
    // Since original IDs don't match, we search by name similarity.
    final folder = library.folders.where((f) {
      final t = f.title.toLowerCase();
      // Check if folder title contains a transliterated version or if we have a direct map
      // This is a heuristic until we have a perfect f-ID map.
      return t.contains(normalized.toLowerCase()) || 
             (normalized == 'መዝሙረዳዊት' && t.contains('mezmuredawit')) ||
             (normalized == 'የዮሐንስወንጌል' && t.contains('yohanes_wongl'));
    }).firstOrNull;

    if (folder == null) return null;

    final ch = int.tryParse(chapter.toString().replaceAll(RegExp(r'[^0-9]'), ""));
    if (ch == null) return null;

    // 3. Find track in folder by chapter number
    return library.byFolder[folder.id]?.where((t) {
      final m = RegExp(r'(\d+)').firstMatch(t.title);
      return m != null && int.tryParse(m.group(1)!) == ch;
    }).firstOrNull;
  }

  AudioFolder? findKidassieFolder(String label) {
    if (!isLoaded) return null;
    return library.folders.where((f) => f.title.contains(label)).firstOrNull;
  }
}
