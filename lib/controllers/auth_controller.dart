import 'package:firebase_auth/firebase_auth.dart';
import 'package:pokedex_app/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<User?> register(String email,String password){
    return _authService.signUp(email, password);
  }

  Future<User?> login(String email, String password){
    return _authService.signIn(email, password);
  }

  Future<void> logout(){
    return _authService.signOut();
  }


}
