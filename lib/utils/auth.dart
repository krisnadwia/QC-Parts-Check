import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Auth {
  // This method is used to create the user in Firestore
  static Future<void> createUser(String? uid, String displayName, String mail, String phoneNumber) async {
    // Creates the user doc named whatever the user uid is in the collection "users" and adds the user data
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set({
      "uid": uid,
      "name": displayName,
      "email": mail,
      "phone": phoneNumber,
    });
  }

  static Future<String?> mailRegister(String mail, String pwd, String displayName, String phoneNumber) async {
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

  static Future<String?> mailSignIn(String mail, String pwd) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: pwd,
      );

      // Get the user doc with the uid of the user that just logged in
      DocumentReference ref = FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user?.uid);
      DocumentSnapshot documentSnapshot = await ref.get();

      // Print the user"s name or do whatever you want to do with it
      if (kDebugMode) {
        print("${documentSnapshot["name"]}");
      }
      return null;
      
    } on FirebaseAuthException catch (ex) {
      return "${ex.code}: ${ex.message}";
    }
  }
}
