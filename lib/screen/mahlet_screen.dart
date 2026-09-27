import 'package:flutter/material.dart';
import '../services/gitsawe_service.dart';
import '../models/mahlet.dart';
import '../widgets/gitsawe_app_bar.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../widgets/screen_wrapper.dart';

class MahletScreen extends StatelessWidget {
  const MahletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final List<Mahlet> mahlets = GitsaweService.instance.mahlets;

    return ScreenWrapper(
      currentIndex: 4,
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
                        border: Border.all(color: colors.outlineVariant.withOpacity(0.45)),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.15),
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                              Icon(IconsaxPlusLinear.arrow_right_3, color: colors.onSurfaceVariant),
                            ],
                          ),
                          if (mahlet.source != null && mahlet.source!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'ምንጭ፦ ${mahlet.source}',
                              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
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
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: GitsaweAppBar(title: mahlet.title, showBackArrow: true),
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
                  style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
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
