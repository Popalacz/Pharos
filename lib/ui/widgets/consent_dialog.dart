import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/consent_provider.dart';
import 'package:pharos/l10n/app_localizations.dart';

/// Asks the user whether analytics and crash reports may be sent. Both answers look the same.
Future<void> showConsentDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final consentProvider = context.read<ConsentProvider>();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.consentTitle),
      content: Text(l10n.consentBody),
      actions: [
        TextButton(
          onPressed: () async {
            await consentProvider.setGranted(false);
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
          child: Text(l10n.consentDecline),
        ),
        TextButton(
          onPressed: () async {
            await consentProvider.setGranted(true);
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
          child: Text(l10n.consentAccept),
        ),
      ],
    ),
  );
}

/// Shows the consent dialog once, on the first launch, before the user does anything else.
class ConsentGate extends StatefulWidget {
  const ConsentGate({super.key, required this.child});

  final Widget child;

  @override
  State<ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<ConsentGate> {
  bool _isDialogRequested = false;

  @override
  Widget build(BuildContext context) {
    final consentProvider = context.watch<ConsentProvider>();
    final bool shouldAsk = consentProvider.isLoaded && !consentProvider.hasDecided;

    if (shouldAsk && !_isDialogRequested) {
      _isDialogRequested = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showConsentDialog(context);
      });
    }

    return widget.child;
  }
}
