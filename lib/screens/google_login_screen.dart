import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  static const Color burgundy = Color(0xFF8D1725);
  static const Color darkBurgundy = Color(0xFF5F0D18);
  static const Color cream = Color(0xFFFFF9F6);
  static const Color gold = Color(0xFFC99A3D);

  // ------------------------------------------------------------
  // GOOGLE OAUTH CONFIGURATION
  // ------------------------------------------------------------
  //
  // These values are used for Windows/Desktop Google Sign-In.
  //
  // IMPORTANT:
  // Do NOT commit a real OAuth client secret to GitHub.
  //
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    params: const GoogleSignInParams(
      clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
      clientSecret: 'YOUR_CLIENT_SECRET',
      scopes: ['openid', 'profile', 'email'],
    ),
  );

  bool _isLoading = false;

  // ------------------------------------------------------------
  // WEB GOOGLE LOGIN
  // ------------------------------------------------------------
  //
  // Web does NOT use google_sign_in_all_platforms.
  //
  // Instead, Firebase Authentication directly opens the
  // Google OAuth popup.
  //
  Future<void> _signInWithGoogleWeb() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleAuthProvider googleProvider =
          GoogleAuthProvider();

      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Open Google login popup.
      await FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      );

      debugPrint(
        '✅ Firebase Google Web authentication successful',
      );

      debugPrint(
        'Firebase user: '
        '${FirebaseAuth.instance.currentUser?.email}',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Web Auth error');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: darkBurgundy,
          content: Text(
            'Google login failed: ${e.message ?? e.code}',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Google Web login error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: darkBurgundy,
          content: Text(
            'Google login failed: $e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ------------------------------------------------------------
  // WINDOWS / DESKTOP GOOGLE LOGIN
  // ------------------------------------------------------------

  Future<void> _signInWithGoogle() async {
    // Web uses _signInWithGoogleWeb().
    if (kIsWeb) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Force a fresh Google OAuth flow.
      await _googleSignIn.signOut();

      // Windows/Desktop Google login.
      final credentials =
          await _googleSignIn.signInOnline();

      if (credentials == null) {
        throw Exception(
          'Google sign-in was cancelled.',
        );
      }

      debugPrint(
        'Google access token received: true',
      );

      debugPrint(
        'Google ID token received: '
        '${credentials.idToken != null}',
      );

      // Firebase requires an ID token.
      if (credentials.idToken == null ||
          credentials.idToken!.isEmpty) {
        throw Exception(
          'Google did not return an ID token. '
          'Check the OAuth client configuration.',
        );
      }

      // Create Firebase Google credential.
      final googleCredential =
          GoogleAuthProvider.credential(
        idToken: credentials.idToken,
      );

      // Authenticate with Firebase.
      await FirebaseAuth.instance.signInWithCredential(
        googleCredential,
      );

      debugPrint(
        '✅ Firebase Google authentication successful',
      );

      debugPrint(
        'Firebase user: '
        '${FirebaseAuth.instance.currentUser?.email}',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: darkBurgundy,
          content: Text(
            'Firebase login failed: ${e.code}',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Google login error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: darkBurgundy,
          content: Text(
            'Google login failed: $e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxWidth < 850;

          return Row(
            children: [
              if (!isCompact) _buildBrandPanel(),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(28),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 470,
                      ),
                      child: _buildLoginCard(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // LEFT BRAND PANEL
  // ------------------------------------------------------------

  Widget _buildBrandPanel() {
    return Container(
      width: 360,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            darkBurgundy,
            burgundy,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 35,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(
                        0.15,
                      ),
                      blurRadius: 12,
                      offset:
                          const Offset(0, 6),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.all(12),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/lotus_logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Sree Lakshmi\nCards',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1.15,
                  fontWeight:
                      FontWeight.bold,
                  fontFamily: 'Georgia',
                ),
              ),

              const SizedBox(height: 28),

              Container(
                height: 1,
                width: 150,
                color: gold,
              ),

              const SizedBox(height: 24),

              const Text(
                'Cards for Every Occasion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.4,
                  fontStyle:
                      FontStyle.italic,
                  fontFamily: 'Georgia',
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Manage your products, billing and '
                'invoices with ease.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LOGIN CARD
  // ------------------------------------------------------------

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        34,
        36,
        34,
        32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEAD6D1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9E8),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF1C6BF),
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: burgundy,
              size: 38,
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkBurgundy,
              fontSize: 32,
              fontWeight:
                  FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Sign in to access your '
            'Sree Lakshmi Cards dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '✦  ❖  ✦',
            style: TextStyle(
              color: gold,
              fontSize: 23,
            ),
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // GOOGLE LOGIN
          // --------------------------------------------------
          //
          // WEB:
          // Firebase signInWithPopup()
          //
          // WINDOWS:
          // google_sign_in_all_platforms
          // --------------------------------------------------

          if (kIsWeb)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    _isLoading
                        ? null
                        : _signInWithGoogleWeb,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons
                            .account_circle_outlined,
                        color: Colors.white,
                      ),
                label: Text(
                  _isLoading
                      ? 'Signing in...'
                      : 'Continue with Google',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      burgundy,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFFB97982),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),
                  elevation: 3,
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    _isLoading
                        ? null
                        : _signInWithGoogle,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons
                            .account_circle_outlined,
                        color: Colors.white,
                      ),
                label: Text(
                  _isLoading
                      ? 'Signing in...'
                      : 'Continue with Google',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      burgundy,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFFB97982),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),
                  elevation: 3,
                ),
              ),
            ),

          const SizedBox(height: 22),

          const Text(
            'Secure access powered by '
            'Firebase Authentication',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}