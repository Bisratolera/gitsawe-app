import 'package:flutter/material.dart';
import '../services/audio_library_service.dart';
import '../models/audio.dart';
import '../widgets/audio_play_button.dart';

import '../widgets/screen_wrapper.dart';

class AudioLibraryScreen extends StatefulWidget {
  const AudioLibraryScreen({super.key});

  @override
  State<AudioLibraryScreen> createState() => _AudioLibraryScreenState();
}

class _AudioLibraryScreenState extends State<AudioLibraryScreen> {
  List<AudioCategoryGroup>? _categories;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final lib = await AudioLibraryService.instance.load();
      if (!mounted) return;
      setState(() => _categories = lib.categories);
    } catch (e, st) {
      debugPrint('Audio library load failed: $e\n$st');
      if (!mounted) return;
      setState(() => _error = 'Could not load the audio library.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentIndex: -1, // Not a main tab
      title: 'ድምፅ ቤተ መጻሕፍት',
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final categories = _categories;
    if (categories == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final group = categories[i];
        return ExpansionTile(
          title: Text('${group.category.amharicName} (${group.trackCount})'),
          children: group.folders.map((folder) {
            final tracks = AudioLibraryService.instance.tracksOfFolder(folder.id);
            return ListTile(
              title: Text(folder.title),
              subtitle: Text('${tracks.length} tracks'),
              trailing: AudioPlayButton(tracks: tracks, label: 'አድምጥ'),
            );
          }).toList(),
        );
      },
    );
  }
}