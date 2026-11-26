import 'package:flutter/material.dart';
import 'package:pharos/core/config/legal_config.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Information required before the order is placed: terms, privacy policy and the right of withdrawal.
class CheckoutLegalNotice extends StatelessWidget {
  const CheckoutLegalNotice({super.key});

  Future<void> _openLink(String url) async {
    final Uri? uri = Uri.tryParse(url);

    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final links = <String, String>{
      if (LegalConfig.termsUrl.isNotEmpty) l10n.legalTermsLink: LegalConfig.termsUrl,
      if (LegalConfig.privacyUrl.isNotEmpty) l10n.legalPrivacyLink: LegalConfig.privacyUrl,
      if (LegalConfig.withdrawalUrl.isNotEmpty) l10n.legalWithdrawalLink: LegalConfig.withdrawalUrl,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.checkoutLegalNotice,
          style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.text.withOpacity(0.6)),
        ),
        if (links.isNotEmpty)
          Wrap(
            spacing: 12,
            children: [
              for (final link in links.entries)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  onPressed: () => _openLink(link.value),
                  child: Text(link.key, style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
      ],
    );
  }
}
