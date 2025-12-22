import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


ValueNotifier<AuthService> authService= ValueNotifier(AuthService());

class AuthService {
final FirebaseAuth firebaseAuth=FirebaseAuth.instance;

final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User ? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges() ;


  Future<UserCredential> signIn ({
    required String e,
    required String p,

  }) async {

    return await firebaseAuth.signInWithEmailAndPassword(email: e, password: p) ;
  }


Future<UserCredential> createAccount({
  required String email,
  required String password,
}) async {
  // 1. Create the user in Firebase Auth
  final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final user = firebaseAuth.currentUser; // ensures we use the authenticated user

  // 2. Only write to Firestore if user is not null
  if (user != null) {
    await firestore.collection('Users').doc(user.uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  return userCredential;
}


Future<void> signOut ()
async {
  await firebaseAuth.signOut();
}

Future<void> resetPassword({
  required String e,
}) async {
  return await firebaseAuth.sendPasswordResetEmail(email: e);
}


}
