import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:movie_app/colors.dart';
import 'package:movie_app/screens/splash_screen.dart';
import 'package:movie_app/screens/home_screen.dart';
import 'package:movie_app/screens/login.dart';
import 'package:movie_app/screens/sign_up.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDfDVOnuZsC-uFy-aeeWgxxlBuz9g54UAw",
        appId: "1:900028268549:android:3805be0a39658232cf1c6c",
        messagingSenderId: "900028268549",
        projectId: "movieblitz-151ec",
        // Your web Firebase config options
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colours.scaffoldBgColor,
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => SplashScreen(
          // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
          child: LoginPage(),
        ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}