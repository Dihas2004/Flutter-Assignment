import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/login.dart';
import 'package:movie_app/screens/search.dart';
import 'package:movie_app/widgets/movies_slider.dart';
import 'package:movie_app/widgets/trending_slider.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/widgets/watched_movies.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final Future<List<Movies>> trendingMovies;
  final Future<List<Movies>> topRatedMovies;
  final Future<List<Movies>> grossingMovies;
  final Future<List<Movies>> childrenMovies;
  final Future<List<Movies>> actionChildrenMovies;
  final Future<List<Movies>> romanticChildrenMovies;

  const HomeScreen({
    Key? key,
    required this.trendingMovies,
    required this.topRatedMovies,
    required this.grossingMovies,
    required this.childrenMovies,
    required this.actionChildrenMovies,
    required this.romanticChildrenMovies,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  bool isChildrenFriendly = false;

  @override
  void initState() {
    super.initState();
    
  }

  Future<void> saveLoginStatusToSharedPreferences(bool isLoggedIn) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('login_status', isLoggedIn);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/flutflix.png',
          fit: BoxFit.cover,
          height: 40,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Navigate to the search screen here
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
              onPressed: () {
                setState(() {
                  isChildrenFriendly = !isChildrenFriendly;
                });
              },
              style: ElevatedButton.styleFrom(
                primary: isChildrenFriendly ? Colors.green : Colors.grey,
              ),
              child: Text("Children Friendly"),
            ),
            if (!isChildrenFriendly)...[
              Text(
                'Trending Movies',
                style: GoogleFonts.aBeeZee(fontSize: 25),
              ),
              const SizedBox(height: 32),
              SizedBox(
                child: FutureBuilder(
                  future: widget.trendingMovies,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else if (snapshot.hasData) {
                      return TrendingSlider(snapshot: snapshot);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Top Rated Movies',
                style: GoogleFonts.aBeeZee(
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                child: FutureBuilder(
                  future: widget.topRatedMovies,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else if (snapshot.hasData) {
                      return MoviesSlider(snapshot: snapshot, movieType: 'Top Rated');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Grossing Movies',
                style: GoogleFonts.aBeeZee(
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                child: FutureBuilder(
                  future: widget.grossingMovies,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else if (snapshot.hasData) {
                      return MoviesSlider(snapshot: snapshot, movieType: 'Grossing');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
            if(isChildrenFriendly)...[
              Text(
                'Popular Children Movies',
                style: GoogleFonts.aBeeZee(fontSize: 25),
              ),
              const SizedBox(height: 32),
              SizedBox(
                child: FutureBuilder(
                  future: widget.childrenMovies,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else if (snapshot.hasData) {
                      return TrendingSlider(snapshot: snapshot);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
            if(isChildrenFriendly)...[
              Text(
                'Children Action Movies',
                style: GoogleFonts.aBeeZee(fontSize: 25),
              ),
              const SizedBox(height: 32),
              SizedBox(
                child: FutureBuilder(
                  future: widget.actionChildrenMovies,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else if (snapshot.hasData) {
                      return MoviesSlider(snapshot: snapshot, movieType: 'Action Animation',);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
            if(isChildrenFriendly)...[
              Text(
                'Children Romantic Movies',
                style: GoogleFonts.aBeeZee(fontSize: 25),
              ),
              const SizedBox(height: 32),
              SizedBox(
                child: FutureBuilder(
                  future: widget.romanticChildrenMovies,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else if (snapshot.hasData) {
                      return MoviesSlider(snapshot: snapshot, movieType: 'Romantic Animation',);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],

              const SizedBox(height: 32),
              Text(
                'Watched Movies',
                style: GoogleFonts.aBeeZee(
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 32),
              WatchedMoviesWidget(userId: globalUserId?? 'LYFYEDjpllF7fAkKWtP5'),
              
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  saveLoginStatusToSharedPreferences(false);
                  Navigator.pushNamed(context, "/login");
                  // showToast(message: "Successfully signed out");
                },
                child: Container(
                  height: 45,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      "Sign out",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
