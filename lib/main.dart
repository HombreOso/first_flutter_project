import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/auth_screen.dart';
import 'package:flutter_complete_guide/screens/confirm_email_screen.dart';
import 'package:flutter_complete_guide/screens/splash_screen.dart';

import '../screens/expenses_screen.dart';

import 'screens/add_categories_screen.dart';
import 'screens/forgot_password_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    FutureBuilder(
      // Initialize FlutterFire:
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text(
            "Something went wrong",
            textDirection: TextDirection.ltr,
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Otherwise, show a loading indicator
        return Text(
          "Loading",
          textDirection: TextDirection.ltr,
        );
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.purple,
        secondaryHeaderColor: Colors.amber,
        unselectedWidgetColor: Colors.red,

        // errorColor: Colors.red,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              titleLarge: TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              labelLarge: TextStyle(color: Colors.white),
            ),
        appBarTheme: AppBarTheme(
          titleTextStyle: ThemeData.light().textTheme.titleLarge!.copyWith(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        ),
        iconTheme: IconThemeData(
          color: Colors.amber,
        ),
      ),
      routes: {
        '/expenses': (context) => MyHomePage(),
        '/categories': (context) => CategoryScreen(),
        '/auth': (context) => AuthPage(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/confirm_email': (context) => EmailVerificationScreen(),
      },
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen();
            }
            if (userSnapshot.hasData) {
              return MyHomePage();
            }
            return AuthPage();
          }),
    );
  }
}
