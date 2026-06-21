import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // للـ debugPrint

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // 1. تحديث الاسم
        await userCredential.user!.updateDisplayName(username);
        await userCredential.user!.reload();

        // 2. حفظ البيانات في Firestore
        await _firestore.collection('users').doc(email.toLowerCase()).set({
          'username': username,
          'email': email.toLowerCase(),
          'uid': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3. إرسال إيميل التحقق
        await userCredential.user!.sendEmailVerification();
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // هنا يمكنك التعامل مع أخطاء محددة (مثل الإيميل موجود مسبقاً)
      debugPrint("Auth Error: ${e.message}");
      rethrow; // نعيد رمي الخطأ ليعرف الـ UI ما الذي حدث ويعرض رسالة للمستخدم
    } catch (e) {
      debugPrint("General Error: $e");
      return null;
    }
  }

  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Login Error: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("General Login Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
