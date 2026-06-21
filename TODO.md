# TODO - Fix `AuthService` Google Sign-In compile errors

- [ ] Update `lib/services/auth_service.dart` to use the correct `google_sign_in` v7.2.0 API for Chrome/web
- [ ] Remove unsupported calls (`GoogleSignIn.standard`, `_googleSignIn.signIn`, `googleAuth.accessToken`), replace with correct credential creation
- [ ] Run `flutter analyze` and ensure there are no remaining errors from `auth_service.dart`
