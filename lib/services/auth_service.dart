import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  String? get currentUserId;
}

class RealAuthService implements AuthService {
  @override
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
}
