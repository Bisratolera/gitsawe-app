import 'package:flutter/material.dart';
import '../models/daily_gitsawe.dart';
import '../services/gitsawe_service.dart';
import '../widgets/gitsawe_app_bar.dart';
import '../widgets/gitsawe_view.dart';

import '../widgets/screen_wrapper.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenWrapper(
      currentIndex: 3,
      title: 'ፍለጋ',
      body: _SearchBody(),
    );
  }
}

class _SearchBody extends StatefulWidget {
  const _SearchBody();

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final all = GitsaweService.instance.allDaily;
    final results = _query.isEmpty
        ? [] // Don't show everything initially
        : all.where((d) => 
            d.title.toLowerCase().contains(_query.toLowerCase()) ||
            d.date.contains(_query)
          ).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search titles or dates (e.g. 01-01)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        if (_query.isEmpty)
          const Expanded(
            child: Center(
              child: Text('Enter a search term to find readings'),
            ),
          )
        else if (results.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No results found'),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (context, i) {
                final d = results[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(d.title),
                    subtitle: Text(d.date),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => _DailyDetail(d))
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

class _DailyDetail extends StatelessWidget {
  final DailyGitsawe daily;
  const _DailyDetail(this.daily);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GitsaweAppBar(title: daily.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GitsaweView(
          entry: daily,
          dateLabel: daily.date, // Use the DD-MM as the label
        ),
      ),
    );
  }
}
