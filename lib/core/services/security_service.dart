import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticateForPayment() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return true; // Jeśli urządzenie nie wspiera, przepuszczamy (MVP)

      return await _auth.authenticate(
        localizedReason: 'Potwierdź płatność w Pharos Biometric Pay',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Biometric Error: $e');
      return false;
    }
  }
}
