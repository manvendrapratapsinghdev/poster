import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn;

  GoogleSignInService({required String serverClientId})
      : _googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'profile',
            'openid'
          ],
          serverClientId: serverClientId,
          forceCodeForRefreshToken: true,
        );

  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

