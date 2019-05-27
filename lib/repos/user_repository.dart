import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {

 static const userNameKey = "username";
 static const mobileKey = "mobile";
 static const signedInKey = "signedIn";

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

  Future<void> signUp({String username, String mobile}) async {
    return await prefs.then((onValue) {
      onValue.setString(userNameKey, username);
      onValue.setString(mobileKey, mobile);
      onValue.setString(signedInKey, "true");
    });
  }

  Future<void> signOut() async {
    return await prefs.then((onValue) {
      onValue.clear();
    });
  }

  Future<bool> isSignedIn() async {
    return await prefs.then((onValue) {
      return onValue.containsKey(signedInKey);
    });
  }

  Future<String> getUser() async {
    return await prefs.then((onValue) {
      if (onValue.containsKey(userNameKey))
        return onValue.getString(userNameKey);
      else
        return "";
    });
  }
}
