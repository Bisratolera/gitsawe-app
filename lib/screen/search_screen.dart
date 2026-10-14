import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../core/l10n/strings.dart';
import '../core/utils/ethiopian_calendar.dart';
import '../services/gitsawe_service.dart';
import 'daily_gitsawe_screen.dart';

import '../widgets/screen_wrapper.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentIndex: 5,
      title: tr(context, 'title_search'),
      body: const _SearchBody(),
    );
  }
}

class _SearchBody extends StatefulWidget {
  const _SearchBody();

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<SearchHit> _hits = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // Full-text search walks every reading, so wait for a pause in typing.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _query = value.trim();
        _hits = GitsaweService.instance.searchDaily(_query);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final english = LangScope.of(context) == 'en';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _debounce?.cancel();
                        setState(() {
                          _query = '';
                          _hits = const [];
                        });
                      },
                    ),
              hintText: tr(context, 'search_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest,
            ),
            onChanged: (v) {
              setState(() {}); // refresh the clear button
              _onChanged(v);
            },
          ),
        ),
        if (_query.isEmpty)
          Expanded(
            child: Center(
              child: Text(tr(context, 'search_empty')),
            ),
          )
        else if (_hits.isEmpty)
          Expanded(
            child: Center(
              child: Text(tr(context, 'search_none')),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _hits.length,
              itemBuilder: (context, i) {
                final hit = _hits[i];
                final d = hit.entry;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(d.title),
                    subtitle: Text(
                      hit.snippet.isEmpty
                          ? formatDateKey(d.date, english: english)
                          : '${formatDateKey(d.date, english: english)} · ${hit.snippet}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(IconsaxPlusLinear.arrow_right_3),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DailyGitsaweDetailScreen(entry: d)),
                    ),
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}
