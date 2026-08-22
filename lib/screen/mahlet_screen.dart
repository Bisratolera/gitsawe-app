import 'package:flutter/material.dart';
import '../services/gitsawe_service.dart';
import '../models/mahlet.dart';
import '../core/theme/app_theme.dart';
import '../widgets/gitsawe_app_bar.dart';
import '../widgets/app_sidebar.dart';

import '../widgets/screen_wrapper.dart';

class MahletScreen extends StatelessWidget {
  const MahletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Mahlet> mahlets = GitsaweService.instance.mahlets;

    return ScreenWrapper(
      currentIndex: 2,
      title: 'ሥርዓተ ማኅሌት',
      body: mahlets.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('ምንም ማኅሌት አልተገኘም።'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mahlets.length,
              itemBuilder: (context, i) {
                final mahlet = mahlets[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _MahletDetailScreen(mahlet: mahlet),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  mahlet.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.maroon,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.black26),
                            ],
                          ),
                          if (mahlet.source != null && mahlet.source!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'ምንጭ፦ ${mahlet.source}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _MahletDetailScreen extends StatelessWidget {
  final Mahlet mahlet;

  const _MahletDetailScreen({required this.mahlet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GitsaweAppBar(title: mahlet.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mahlet.source != null && mahlet.source!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'ምንጭ፦ ${mahlet.source}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            ...mahlet.details.map((detail) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.maroon,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail.verse,
                      style: const TextStyle(fontSize: 16, height: 1.7),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
