import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/api/api.dart';
import 'package:movie_app/colors.dart';
import 'package:movie_app/models/movie.dart';
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
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDfDVOnuZsC-uFy-aeeWgxxlBuz9g54UAw",
        appId: "1:900028268549:android:3805be0a39658232cf1c6c",
        messagingSenderId: "900028268549",
        projectId: "movieblitz-151ec",
      ),
    );
  }
  runApp(MyApp(
    trendingMovies: API().getTrendingMovies(),
    topRatedMovies: API().getTopRatedMovies(),
    grossingMovies: API().getGrossingMovies(),
    childrenMovies: API().getChildMovies(),
    actionChildrenMovies: API().getActionChildMovies(),
    romanticChildrenMovies: API().getRomanticChildMovies(),
  ));
}

class MyApp extends StatelessWidget {
  final Future<List<Movies>> trendingMovies;
  final Future<List<Movies>> topRatedMovies;
  final Future<List<Movies>> grossingMovies;
  final Future<List<Movies>> childrenMovies;
  final Future<List<Movies>> actionChildrenMovies;
  final Future<List<Movies>> romanticChildrenMovies;

  const MyApp({
    Key? key,
    required this.trendingMovies,
    required this.topRatedMovies,
    required this.grossingMovies,
    required this.childrenMovies,
    required this.actionChildrenMovies,
    required this.romanticChildrenMovies,
  }) : super(key: key);

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
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(
        ),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomeScreen(
          trendingMovies: trendingMovies,
          topRatedMovies: topRatedMovies,
          grossingMovies: grossingMovies,
          childrenMovies: childrenMovies,
          actionChildrenMovies: actionChildrenMovies,
          romanticChildrenMovies: romanticChildrenMovies,
        ),
      },
    );
  }
}
