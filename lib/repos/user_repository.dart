import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  UserRepository() {
    prefs = SharedPreferences.getInstance();
  }

  // Future<void> signInWithCredentials(String email, String password) {
  //   return _firebaseAuth.signInWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   );
  // }

  Future<void> signUp({String email, String password}) async {
    return await prefs.then((onValue) {
      onValue.setString('email', email);
      onValue.setString('password', password);
      onValue.setString('SignedIn', "true");
    });
  }

  Future<void> signOut() async {
    return await prefs.then((onValue) {
      onValue.clear();
    });
  }

  Future<bool> isSignedIn() async {
    return await prefs.then((onValue) {
      onValue.containsKey("SignedIn");
    });
  }

  Future<String> getUser() async {
    return await prefs.then((onValue) {
      // if (onValue.containsKey("email"))
      return onValue.getString("email") ?? "";
    });
  }
}
