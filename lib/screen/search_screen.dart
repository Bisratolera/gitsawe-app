import 'package:flutter/material.dart';
import '../models/daily_gitsawe.dart';
import '../services/gitsawe_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final all = GitsaweService.instance.allDaily;
    final results = _query.isEmpty
        ? all
        : all.where((d) => d.title.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search titles'),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, i) {
                final d = results[i];
                return ListTile(
                  title: Text(d.title),
                  subtitle: Text(d.date),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _DailyDetail(d))),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class _DailyDetail extends StatelessWidget {
  final DailyGitsawe daily;
  const _DailyDetail(this.daily, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(daily.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(daily.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('ስንክሳር', style: TextStyle(fontWeight: FontWeight.bold)),
            ...daily.snksar.map((s) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(s.amharic),
                )),
          ],
        ),
      ),
    );
  }
}
