import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  // This method is used to create the user in Firestore
  static Future<void> createUser(String? uid, String displayName, String mail, String phoneNumber, String role) async {
    // Creates the user doc named whatever the user uid is in the collection "users" and adds the user data
    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      "uid": uid,
      "name": displayName,
      "email": mail,
      "phone": phoneNumber,
      "role": role,
    });
  }

  static Future<String?> mailRegister(
      String mail, String pwd, String displayName, String phoneNumber, String role) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: mail,
        password: pwd,
      );

      // Create the user in Firestore with the user data
      createUser(
        userCredential.user?.uid,
        displayName,
        mail,
        phoneNumber,
        role,
      );
      return null;
    } on FirebaseAuthException catch (ex) {
      return "${ex.code}: ${ex.message}";
    }
  }

  static Future<String?> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return null;
    } on FirebaseAuthException catch (ex) {
      return "${ex.code}: ${ex.message}";
    }
  }
}
