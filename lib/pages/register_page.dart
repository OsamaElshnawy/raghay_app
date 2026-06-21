import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:raghay_app/constants.dart';
import 'package:raghay_app/pages/verify_email_page.dart';
import 'package:raghay_app/services/auth_service.dart';
import 'package:raghay_app/widgets/custom_button.dart';
import 'package:raghay_app/widgets/custom_text_form_filed.dart';
import 'package:raghay_app/widgets/show_snack_bar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static String id = 'RegisterPage';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // 🎯 تنظيم الـ Validators لجعل الكود أنظف
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters long.';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must contain at least one lowercase letter.';
    }
    if (!RegExp(r'[!@#\$&*~._-]').hasMatch(value)) {
      return 'Must contain at least one special character.';
    }
    return null;
  }

  void _onRegisterPressed() async {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await _authService.registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
        );

        if (!mounted) return;
        setState(() => isLoading = false);

        showSnackBar(
          context,
          'Registered successfully! Redirecting to verification...',
        );

        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        Navigator.pushReplacementNamed(context, VerifyEmailPage.id);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => isLoading = false);
        _handleFirebaseError(context, e);
      } catch (e) {
        if (!mounted) return;
        setState(() => isLoading = false);
        showSnackBar(context, 'An unexpected error occurred: ${e.toString()}');
      }
    }
  }

  void _handleFirebaseError(BuildContext context, FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      showSnackBar(context, 'The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      showSnackBar(context, 'The account already exists for that email.');
    } else if (e.code == 'invalid-email') {
      showSnackBar(context, 'The email address is not valid.');
    } else {
      showSnackBar(context, e.message ?? 'Authentication failed.');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return ModalProgressHUD(
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
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  controller: _usernameController,
                  obscureText: false,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please Enter User Name'
                      : null,
                  hintText: 'User Name',
                  icon: const Icon(Icons.person, color: Colors.white),
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
                    if (!value.contains('@')) return 'Please Enter Valid Email';
                    return null;
                  },
                  hintText: 'Email',
                  icon: const Icon(Icons.email, color: Colors.white),
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  textInputAction: TextInputAction.next,
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
                  validator: _validatePassword,
                  hintText: 'Password',
                  icon: const Icon(Icons.lock, color: Colors.white),
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordObscured,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white60,
                    ),
                    onPressed: () => setState(
                      () => _isConfirmPasswordObscured =
                          !_isConfirmPasswordObscured,
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'The password does not match!';
                    }
                    return null;
                  },
                  hintText: 'Confirm Password',
                  icon: const Icon(Icons.lock, color: Colors.white),
                ),
                const SizedBox(height: 15),
                CustomButton(title: 'Register', onPressed: _onRegisterPressed),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "already have an account? ",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
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
    );
  }
}
