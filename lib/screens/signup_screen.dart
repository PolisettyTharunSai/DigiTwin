import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/location_service.dart';
import 'get_started_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  // Location
  double? lat;
  double? lng;

  // UI state
  bool loading = false;
  bool locationFetched = false;
  bool locationLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  static const primaryColor = Color(0xFF7F3DFF);

  String safeText(TextEditingController c) =>
      c.text.replaceAll(RegExp(r'\s+'), '').trim();

  // 📍 Get live location
  Future<void> getLocation() async {
    setState(() => locationLoading = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      setState(() {
        lat = pos.latitude;
        lng = pos.longitude;
        locationFetched = true;
      });
    } catch (_) {
      _toast("Failed to get location");
    }
    setState(() => locationLoading = false);
  }

  // 📝 SIGN UP
  Future<void> signup() async {
    final name = safeText(nameCtrl);
    final email = safeText(emailCtrl);
    final phone = safeText(phoneCtrl);
    final password = safeText(passCtrl);
    final confirmPassword = safeText(confirmPassCtrl);

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _toast("Please fill all required fields");
      return;
    }

    if (!locationFetched) {
      _toast("Please get live location");
      return;
    }

    if (password != confirmPassword) {
      _toast("Passwords do not match");
      return;
    }

    setState(() => loading = true);

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone, 'lat': lat, 'lng': lng},
      );

      if (res.user == null) {
        throw const AuthException("User creation failed");
      }

      _showVerifyDialog();
    } on AuthException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast("Signup failed");
    }

    setState(() => loading = false);
  }

  // 📩 Email verification popup
  void _showVerifyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Verify Your Email",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Please verify your email and then sign in to your account.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                (_) => false,
              );
            },
            child: const Text("OK", style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Getting Started",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Create an account to continue",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              _inputField(nameCtrl, "Full Name", Icons.person_outline),
              const SizedBox(height: 16),

              _inputField(emailCtrl, "Email", Icons.email_outlined),
              const SizedBox(height: 16),

              _inputField(phoneCtrl, "Phone Number", Icons.phone_outlined),
              const SizedBox(height: 16),

              _passwordField(
                passCtrl,
                "Password",
                showPassword,
                () => setState(() => showPassword = !showPassword),
              ),
              const SizedBox(height: 16),

              _passwordField(
                confirmPassCtrl,
                "Confirm Password",
                showConfirmPassword,
                () =>
                    setState(() => showConfirmPassword = !showConfirmPassword),
              ),

              const SizedBox(height: 24),

              Center(
                child: OutlinedButton.icon(
                  onPressed: locationLoading ? null : getLocation,
                  icon: locationLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          locationFetched
                              ? Icons.check_circle
                              : Icons.location_on_outlined,
                          color: primaryColor,
                        ),
                  label: Text(
                    locationFetched ? "Captured location" : "Get live location",
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Sign In",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordField(
    TextEditingController ctrl,
    String label,
    bool show,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: !show,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(show ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
