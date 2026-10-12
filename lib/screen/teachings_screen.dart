import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../core/theme/app_theme.dart';
import '../models/appostles.dart';
import '../services/teaching_service.dart';
import '../widgets/screen_wrapper.dart';

class TeachingsScreen extends StatelessWidget {
  const TeachingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ScreenWrapper(
      currentIndex: 2,
      title: 'ትምህርቶች',
      body: FutureBuilder<void>(
        future: TeachingService.instance.load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = TeachingService.instance.documents;
          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('ምንም ትምህርቶች አልተገኙም።'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final chapters = doc.sections;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TeachingDetailScreen(document: doc),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.maroon.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.maroon.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(IconsaxPlusLinear.book_1, color: AppColors.maroon),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${chapters.length} ክፍሎች',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.maroon),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TeachingDetailScreen extends StatelessWidget {
  final TeachingDocument document;

  const TeachingDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentIndex: 2,
      title: document.title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final section in document.sections) _buildSection(section),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(Section section) {
    final children = <Widget>[];

    for (final node in section.content) {
      if (node.type == 'paragraph' && node.text != null && node.text!.trim().isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              node.text!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
                color: Colors.black87,
              ),
            ),
          ),
        );
      }

      if (node.type == 'list') {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in node.items)
                  _buildListItem(item, 0),
              ],
            ),
          ),
        );
      }
    }

    final nested = <Widget>[];
    for (final child in section.subSections) {
      nested.add(_buildSection(child));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.heading.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                section.heading,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.maroon,
                ),
              ),
            ),
          ...children,
          ...nested,
        ],
      ),
    );
  }

  Widget _buildListItem(ListItemNode item, int depth) {
    final indent = depth * 18.0;
    final children = <Widget>[];

    if (item.text.trim().isNotEmpty) {
      children.add(
        Padding(
          padding: EdgeInsets.only(left: indent, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16, color: AppColors.maroon)),
              Expanded(
                child: Text(
                  item.text,
                  style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (item.children.isNotEmpty) {
      for (final child in item.children) {
        children.add(_buildListItem(child, depth + 1));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
