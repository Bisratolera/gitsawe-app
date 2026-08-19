import 'package:flutter/material.dart';
import '../services/gitsawe_service.dart';
import '../models/mahlet.dart'; // Safely resolved and used now!
import '../core/theme/app_theme.dart';

class MahletScreen extends StatelessWidget {
  const MahletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // CHANGED: Swapped List<dynamic> to List<Mahlet> to register the type properly
final List<Mahlet> mahlets = GitsaweService.instance.mahlets;

    return Scaffold(
      appBar: AppBar(title: const Text('ሥርዓተ ማህሌት')),
      body: mahlets.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('ምንም ማህሌት አልተገኘም።'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mahlets.length,
              itemBuilder: (context, i) {
                final mahlet = mahlets[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mahlet.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon,
                          ),
                        ),
                        if (mahlet.source != null && mahlet.source!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'ምንጭ፦ ${mahlet.source}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                        if (mahlet.details.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          ...mahlet.details.asMap().entries.map((entry) {
                            final detail = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail.key,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.maroon,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    detail.verse,
                                    style: const TextStyle(fontSize: 14, height: 1.6),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
