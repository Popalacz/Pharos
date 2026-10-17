import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:pharos/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loc = context.watch<LocalizationProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = loc.currentLanguageCode;
    final openingHours = settings.openingHoursFor(languageCode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.contact.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PharosLayout.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoreHeader(context, settings),
            const SizedBox(height: AppSpacing.s32),
            if (_hasText(settings.storeEmail))
              _buildContactCard(
                icon: Icons.email_outlined,
                title: l10n.email,
                value: settings.storeEmail!,
                onTap: () => _launchUrl('mailto:${settings.storeEmail}'),
              ),
            if (_hasText(settings.storeEmail)) const SizedBox(height: AppSpacing.s16),
            if (_hasText(settings.storePhone))
              _buildContactCard(
                icon: Icons.phone_outlined,
                title: l10n.phone,
                value: settings.storePhone!,
                onTap: () => _launchUrl('tel:${settings.storePhone}'),
              ),
            if (_hasText(settings.storePhone)) const SizedBox(height: AppSpacing.s16),
            if (_hasText(settings.storeAddress))
              _buildContactCard(
                icon: Icons.location_on_outlined,
                title: l10n.address,
                value: settings.storeAddress!,
                onTap: settings.hasContactMap
                    ? () => _launchUrl(
                          'https://www.google.com/maps/search/?api=1&query=${settings.latitude},${settings.longitude}',
                        )
                    : null,
              ),
            if (_hasText(settings.storeAddress)) const SizedBox(height: AppSpacing.s24),
            if (settings.hasContactMap) ...[
              _ContactMapSection(
                latitude: settings.latitude!,
                longitude: settings.longitude!,
                storeName: settings.storeName,
              ),
              const SizedBox(height: AppSpacing.s24),
            ],
            if (openingHours.isNotEmpty) ...[
              Text(
                l10n.openingHours,
                style: const TextStyle(
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildOpeningHours(openingHours),
              const SizedBox(height: AppSpacing.s40),
            ],
            _buildSocialSection(context, settings),
            if (!_hasText(settings.storeEmail) &&
                !_hasText(settings.storePhone) &&
                !_hasText(settings.storeAddress) &&
                !settings.hasVisibleSocialMedia)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  l10n.contactUnavailable,
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader(BuildContext context, dynamic settings) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        children: [
          if (settings.brandingEnabled && settings.logoUrl != null)
            ClipOval(
              child: Image.network(
                settings.logoUrl!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildStoreIcon(),
              ),
            )
          else
            _buildStoreIcon(),
          const SizedBox(height: AppSpacing.s16),
          Text(
            settings.storeName,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.officialMobileApp,
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreIcon() {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: const Icon(Icons.storefront_rounded, size: 40, color: AppColors.accentText),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
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
              child: Icon(icon, color: AppColors.accentText, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
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

  Widget _buildSocialSection(BuildContext context, dynamic settings) {
    final l10n = AppLocalizations.of(context)!;
    if (!settings.hasVisibleSocialMedia) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.followUs,
          style: const TextStyle(
            color: Colors.white24,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          children: [
            if (settings.hasVisibleInstagram)
              _socialIcon(Icons.camera_alt_outlined, () => _launchUrl(settings.instagramUrl!)),
            if (settings.hasVisibleFacebook)
              _socialIcon(Icons.facebook_outlined, () => _launchUrl(settings.facebookUrl!)),
            if (settings.hasVisibleTiktok)
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

  Widget _buildOpeningHours(List<dynamic> hours) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: hours.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.day,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                ),
                Text(
                  entry.time,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

//Map Section Google Map 
class _ContactMapSection extends StatelessWidget {
  const _ContactMapSection({
    required this.latitude,
    required this.longitude,
    required this.storeName,
  });

  final double latitude;
  final double longitude;
  final String storeName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storeLocation = LatLng(latitude, longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: storeLocation, zoom: 15),
              markers: {
                Marker(
                  markerId: const MarkerId('store'),
                  position: storeLocation,
                  infoWindow: InfoWindow(title: storeName),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        TextButton.icon(
          onPressed: () async {
            final uri = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          icon: const Icon(Icons.map_outlined, color: AppColors.accentText),
          label: Text(l10n.openInMaps),
        ),
      ],
    );
  }
}
