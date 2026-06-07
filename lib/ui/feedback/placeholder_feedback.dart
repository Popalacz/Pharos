import 'package:flutter/material.dart';

/// Short feedback for actions that are not implemented yet (better than silent no-op).
void showComingSoonSnackBar(BuildContext context) {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    const SnackBar(
      content: Text('Ta funkcja pojawi się wkrótce.'),
    ),
  );
}
