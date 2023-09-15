// ignore_for_file: unused_local_variable, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_constants.dart';
import '../screens/confirm_email_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

class AuthService {
  // Google Sign In
  signInWithGoogle() async {
    print("Enter sign service");
    // begin interactive sign in process
    final GoogleSignInAccount? gUser =
        await GoogleSignIn(scopes: ['email', 'profile']).signIn();
    print("GoogleSignInAccount done");

    // obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    print("GoogleSignInAuthentication done");
    // create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    print("GoogleAuthProvider done");

    // sign in
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
