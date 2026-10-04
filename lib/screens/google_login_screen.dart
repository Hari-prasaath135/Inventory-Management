
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
  // ------------------------------------------------------------
  // THEME COLORS
  // ------------------------------------------------------------

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkText = Color(0xFF0F172A);
  static const Color background = Color(0xFFF8FAFC);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color secondaryText = Color(0xFF475569);
  static const Color lightBlue = Color(0xFFEFF6FF);

  // ------------------------------------------------------------
  // GOOGLE OAUTH CONFIGURATION
  // ------------------------------------------------------------

  // These values are used for Windows/Desktop Google Sign-In.
  //
  // IMPORTANT:
  // Do NOT commit a real OAuth client secret to GitHub.

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    params: const GoogleSignInParams(
      clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
      clientSecret: 'YOUR_CLIENT_SECRET',
      scopes: [
        'openid',
        'profile',
        'email',
      ],
    ),
  );

  bool _isLoading = false;

  // ------------------------------------------------------------
  // WEB GOOGLE LOGIN
  // ------------------------------------------------------------

  // Web uses Firebase Authentication directly.
  // Firebase opens the Google OAuth popup.

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
        'Firebase Google Web authentication successful',
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
          backgroundColor: primaryBlue,
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
          backgroundColor: primaryBlue,
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
        'Firebase Google authentication successful',
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
          backgroundColor: primaryBlue,
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
          backgroundColor: primaryBlue,
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
    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
          surface: Colors.white,
        ),

        scaffoldBackgroundColor: background,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: darkText,
          elevation: 0,
          centerTitle: false,
        ),

        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            side: BorderSide(
              color: borderColor,
            ),
          ),
        ),

        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: borderColor,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: borderColor,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: primaryBlue,
              width: 2,
            ),
          ),
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),
      ),

      child: Scaffold(
        backgroundColor: background,

        body: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                constraints.maxWidth < 850;

            return Row(
              children: [
                if (!isCompact)
                  _buildBrandPanel(),

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

                        child:
                            _buildLoginCard(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
            Color(0xFF1D4ED8),
            primaryBlue,
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
              // ------------------------------------------------
              // LOGO
              // ------------------------------------------------

              Container(
                width: 100,
                height: 100,

                decoration:
                    BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.15),

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
                    'assets/images/lovely_lakshmi.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // BRAND NAME
              // ------------------------------------------------

              const Text(
                'Sree Lakshmi Cards & Bags',

                textAlign:
                    TextAlign.center,

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

              // ------------------------------------------------
              // DIVIDER
              // ------------------------------------------------

              Container(
                height: 1,
                width: 150,
                color: Colors.white70,
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // TAGLINE
              // ------------------------------------------------

              const Text(
                'Cards for Every Occasion',

                textAlign:
                    TextAlign.center,

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

              // ------------------------------------------------
              // DESCRIPTION
              // ------------------------------------------------

              const Text(
                'Manage your products, billing and '
                'invoices with ease.',

                textAlign:
                    TextAlign.center,

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
      padding:
          const EdgeInsets.fromLTRB(
        34,
        36,
        34,
        32,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color: borderColor,
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset:
                Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          // ----------------------------------------------------
          // WELCOME TEXT
          // ----------------------------------------------------

          const Text(
            'Welcome Back',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color: darkText,
              fontSize: 32,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Sign in to access your '
            'Sree Lakshmi Cards dashboard',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color: secondaryText,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 30),

          // ----------------------------------------------------
          // GOOGLE SIGN-IN
          // ----------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 54,

            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : (kIsWeb
                      ? _signInWithGoogleWeb
                      : _signInWithGoogle),

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
                    primaryBlue,

                foregroundColor:
                    Colors.white,

                disabledBackgroundColor:
                    const Color(0xFF93B4F4),

                disabledForegroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ----------------------------------------------------
          // INFORMATION
          // ----------------------------------------------------

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(12),

            decoration:
                BoxDecoration(
              color: lightBlue,

              borderRadius:
                  BorderRadius.circular(8),

              border: Border.all(
                color:
                    const Color(0xFFBFDBFE),
              ),
            ),

            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: primaryBlue,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Sign in securely using your '
                    'Google account.',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Powered by Firebase Authentication',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

