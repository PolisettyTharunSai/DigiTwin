import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'get_started_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  static const primaryColor = Color(0xFFFF9644);

  Future<void> signup() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _toast("Please fill all required fields");
      return;
    }
    
    if (password != confirmPassCtrl.text.trim()) {
      _toast("Passwords do not match");
      return;
    }

    setState(() => loading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Create user in Supabase Auth
      // The trigger on_auth_user_created handles inserting into public.profile
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // Metadata can be used by the trigger to populate profile.name
      );

      final user = res.user;
      if (user == null) throw Exception("Signup failed");

      // 2. Sync name to local storage for immediate UI use if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('farmerName', name);

      if (res.session == null) {
        _showVerifyDialog(email);
      } else {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const GetStartedScreen()),
            (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains("already registered") || msg.contains("user_already_exists")) {
        _toast("Account already exists! Please Sign In.");
      } else if (e.statusCode == '429' || msg.contains("rate limit")) {
        _toast("A verification email was recently sent. Please check your inbox.");
      } else {
        _toast(e.message);
      }
    } catch (e) {
      _toast("Signup failed: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _resendEmail(String email) async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      _toast("Verification email sent!");
    } on AuthException catch (e) {
      if (e.statusCode == '429' || e.message.toLowerCase().contains("rate limit")) {
        _toast("Please wait a while before requesting another email.");
      } else {
        _toast(e.message);
      }
    } catch (e) {
      _toast("Failed to resend: $e");
    }
  }

  void _showVerifyDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Verify Your Email", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("We sent a verification link to $email. Please check your inbox."),
        actions: [
          TextButton(
            onPressed: () => _resendEmail(email),
            child: const Text("Resend Email", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                (_) => false,
              );
            },
            child: const Text("OK", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
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
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Getting Started", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text("Create an account to continue", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              _inputField(nameCtrl, "Full Name", Icons.person_outline),
              const SizedBox(height: 16),
              _inputField(emailCtrl, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _passwordField(passCtrl, "Password", showPassword, () => setState(() => showPassword = !showPassword)),
              const SizedBox(height: 16),
              _passwordField(confirmPassCtrl, "Confirm Password", showConfirmPassword, () => setState(() => showConfirmPassword = !showConfirmPassword)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Sign In", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _passwordField(TextEditingController ctrl, String label, bool show, VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: !show,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(icon: Icon(show ? Icons.visibility_off : Icons.visibility), onPressed: toggle),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
