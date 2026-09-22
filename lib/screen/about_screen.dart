import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/gitsawe_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroonDark,
      appBar: GitsaweAppBar(title: 'About', showBackArrow: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset('assets/images/splash.png', color: Colors.white),
              ),
              const SizedBox(height: 28),
              const Text(
                'About Gitsawe',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Gitsawe is a liturgical companion for the Ethiopian Orthodox '
                'Tewahedo Church. It brings together daily readings, hymns, '
                'Mahilet, Seatat, and Kidan in one place—helping you stay '
                'connected to the rhythm of the Church calendar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 20),
              const Text(
                'Use it to follow Bible readings, reflect on daily prayers, '
                'and keep the liturgy close to your heart.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 60),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              const ListTile(
                title: Text('Version', style: TextStyle(color: Colors.white70)),
                trailing: Text('1.0.0', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 40),
              const Text(
                'developed in love by @thesudoguy',
                style: TextStyle(color: Colors.white38, fontFamily: 'monospace', fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}