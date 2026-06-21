import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:raghay_app/constants.dart';
import 'package:raghay_app/pages/chats_hub_page.dart';
import 'package:raghay_app/widgets/custom_button.dart';
import 'package:raghay_app/widgets/show_snack_bar.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  static String id = 'VerifyEmailPage';

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  bool _canResendEmail = true;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (mounted) showSnackBar(context, e.message ?? 'Error sending email');
    } catch (e) {
      if (mounted) showSnackBar(context, 'Unexpected error: ${e.toString()}');
    }
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload(); // تحديث حالة المستخدم من السيرفر

    if (user.emailVerified) {
      _timer?.cancel();
      if (!mounted) return;

      showSnackBar(context, 'Email verified successfully! 🎉');

      Navigator.pushReplacementNamed(
        context,
        ChatsHubPage.id,
        arguments: user.email,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread_rounded,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 30),
            const Text(
              'Verify your Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'A verification link has been sent to your email. Please check your inbox or Spam folder.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            CustomButton(
              title: _canResendEmail
                  ? 'Resend Email'
                  : 'Wait before resending...',
              onPressed: _canResendEmail
                  ? () async {
                      await _sendVerificationEmail();
                      setState(() => _canResendEmail = false);
                      Future.delayed(const Duration(seconds: 30), () {
                        if (mounted) setState(() => _canResendEmail = true);
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
