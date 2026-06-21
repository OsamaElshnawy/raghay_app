import 'package:firebase_auth/firebase_auth.dart'; // 🎯 تأكد من وجود هذا الاستيراد
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:raghay_app/firebase_options.dart';
import 'package:raghay_app/pages/chat_page.dart';
import 'package:raghay_app/pages/chats_hub_page.dart';
import 'package:raghay_app/pages/login_page.dart';
import 'package:raghay_app/pages/register_page.dart';
import 'package:raghay_app/pages/verify_email_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RaghayApp());
}

class RaghayApp extends StatelessWidget {
  const RaghayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raghay',

      // 🎯 التعديل هنا: فحص حالة الجلسة والإيميل تلقائياً عند فتح التطبيق
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? LoginPage.id
          : (FirebaseAuth.instance.currentUser!.emailVerified
                ? ChatsHubPage.id
                : VerifyEmailPage.id),

      routes: {
        LoginPage.id: (context) => const LoginPage(),
        RegisterPage.id: (context) => const RegisterPage(),
        VerifyEmailPage.id: (context) => const VerifyEmailPage(),
        ChatsHubPage.id: (context) => const ChatsHubPage(),
        ChatPage.id: (context) => ChatPage(),
      },
    );
  }
}
