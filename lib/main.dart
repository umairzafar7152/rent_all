import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rent_all/log_in.dart';
import 'package:rent_all/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

Widget _getLandingPage() {
  return StreamBuilder<User>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (BuildContext context, snapshot) {
      if (snapshot.hasData) {
        if (snapshot.data.providerData.length == 1) {
          // logged in using email and password
          return MainPage();
        } else {
          // logged in using other providers
          return MainPage();
        }
      } else {
        return LogIn();
      }
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _getLandingPage();
  }
}
