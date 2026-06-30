import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('contact').toUpperCase(), 
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PharosLayout.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoreHeader(settings),
            const SizedBox(height: 32),
            _buildContactCard(
              icon: Icons.email_outlined,
              title: 'E-mail',
              value: settings.storeEmail ?? 'kontakt@pharos.pl',
              onTap: () => _launchUrl('mailto:${settings.storeEmail ?? "kontakt@pharos.pl"}'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'Telefon',
              value: settings.storePhone ?? '+48 000 000 000',
              onTap: () => _launchUrl('tel:${settings.storePhone ?? "+48000000000"}'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.location_on_outlined,
              title: 'Adres',
              value: settings.storeAddress ?? 'ul. Piękna 1\n00-001 Warszawa',
              onTap: null,
            ),
            const SizedBox(height: 40),
            const Text(
              'GODZINY OTWARCIA',
              style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            _buildOpeningHours(),
            const SizedBox(height: 40),
            _buildSocialSection(settings),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader(dynamic settings) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent.withOpacity(0.2)),
            ),
            child: const Icon(Icons.storefront_rounded, size: 40, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          Text(
            settings.storeName,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Oficjalna aplikacja mobilna',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({required IconData icon, required String title, required String value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white12),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialSection(dynamic settings) {
    final hasSocial = settings.instagramUrl != null || settings.facebookUrl != null || settings.tiktokUrl != null;
    if (!hasSocial) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OBSERWUJ NAS',
          style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (settings.instagramUrl != null)
              _socialIcon(Icons.camera_alt_outlined, () => _launchUrl(settings.instagramUrl!)),
            if (settings.facebookUrl != null)
              _socialIcon(Icons.facebook_outlined, () => _launchUrl(settings.facebookUrl!)),
            if (settings.tiktokUrl != null)
              _socialIcon(Icons.video_library_outlined, () => _launchUrl(settings.tiktokUrl!)),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white70, size: 24),
        ),
      ),
    );
  }

  Widget _buildOpeningHours() {
    final List<Map<String, String>> hours = [
      {'day': 'Poniedziałek - Piątek', 'time': '09:00 - 18:00'},
      {'day': 'Sobota', 'time': '10:00 - 14:00'},
      {'day': 'Niedziela', 'time': 'Zamknięte'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: hours.map((h) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(h['day']!, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              Text(h['time']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $url');
    }
  }
}
