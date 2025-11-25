import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final  FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up

Future<User?> signUp(String email,String password) async{
  final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  return credential.user;
}

// Sign In
Future<User?> signIn( String email,String password) async {
  final  credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
  return  credential.user;
}

Stream<User?> get userChanges => _auth.authStateChanges();
}