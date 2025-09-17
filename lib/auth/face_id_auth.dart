import 'package:local_auth/local_auth.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<bool> canAuthenticate() async {
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final bool canAuthenticate =
      canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  if (!canAuthenticate) return false;

  return true;
}

Future<bool> authenticateUser() async {
  // final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  // final bool canAuthenticate =
  //     canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  // // ? Try a password approach in this case
  // if (!canAuthenticate) return false;

  final canAuth = await canAuthenticate();
  if (!canAuth) return false;

  try {
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate to view library',
      options: const AuthenticationOptions(
        biometricOnly: false, // Allows fallback to passcode
        stickyAuth: true,
      ),
    );
    return didAuthenticate;
    // return didAuthenticate;
  } catch (e) {
    print("Auth error: $e");
    return false;
  }
}
