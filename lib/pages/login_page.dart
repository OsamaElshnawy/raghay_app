import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:raghay_app/constants.dart';
import 'package:raghay_app/pages/chats_hub_page.dart';
import 'package:raghay_app/pages/register_page.dart';
import 'package:raghay_app/pages/verify_email_page.dart';
import 'package:raghay_app/services/auth_service.dart';
import 'package:raghay_app/widgets/custom_button.dart';
import 'package:raghay_app/widgets/custom_text_form_filed.dart';
import 'package:raghay_app/widgets/show_snack_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String id = 'LoginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isPasswordObscured = true;

  void _onLoginPressed() async {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await _authService.loginWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        User? user = FirebaseAuth.instance.currentUser;
        await user?.reload();
        user = FirebaseAuth.instance.currentUser;

        if (!mounted) return;

        if (user != null && user.emailVerified) {
          showSnackBar(context, 'Login successful.');

          // استخدام pushReplacementNamed لمنع العودة لصفحة Login
          Navigator.pushReplacementNamed(
            context,
            ChatsHubPage.id,
            arguments: _emailController.text.trim(),
          );

          _emailController.clear();
          _passwordController.clear();
        } else {
          showSnackBar(context, 'Please verify your email to continue.');
          Navigator.pushNamed(context, VerifyEmailPage.id);
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        _handleFirebaseError(context, e);
      } catch (e) {
        if (!mounted) return;
        showSnackBar(context, 'An unexpected error occurred: ${e.toString()}');
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  void _handleFirebaseError(BuildContext context, FirebaseAuthException e) {
    if (e.code == 'user-not-found' ||
        e.code == 'wrong-password' ||
        e.code == 'invalid-credential') {
      showSnackBar(context, 'Invalid email or password.');
    } else if (e.code == 'invalid-email') {
      showSnackBar(context, 'The email address is not valid.');
    } else if (e.code == 'user-disabled') {
      showSnackBar(context, 'This user account has been disabled.');
    } else {
      showSnackBar(context, e.message ?? 'Authentication failed.');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: !isLoading,
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Scaffold(
          backgroundColor: kPrimaryColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  SizedBox(height: screenHeight * 0.12),
                  Icon(
                    Icons.forum,
                    size: screenHeight * 0.12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 15),
                  const Center(
                    child: Text(
                      'Raghay',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    controller: _emailController,
                    obscureText: false,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Email';
                      }
                      if (!value.contains('@')) {
                        return 'Please Enter Valid Email';
                      }
                      return null;
                    },
                    hintText: 'Email',
                    icon: const Icon(Icons.email, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white60,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordObscured = !_isPasswordObscured,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required.';
                      }
                      return null;
                    },
                    hintText: 'Password',
                    icon: const Icon(Icons.lock, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  CustomButton(title: 'Login', onPressed: _onLoginPressed),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "don't have an account? ",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () =>
                                  Navigator.pushNamed(context, RegisterPage.id),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: isLoading ? Colors.white30 : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
