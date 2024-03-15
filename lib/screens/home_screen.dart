import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/all_movies_screen.dart';
//import 'package:movie_app/screens/login.dart';
import 'package:movie_app/screens/matching_actors_screen.dart';
import 'package:movie_app/screens/search.dart';
import 'package:movie_app/screens/watch_list_screen.dart';
import 'package:movie_app/screens/watched_screen.dart';
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
  final Future<List<Movies>> trendingWeekMovies;
  final Future<List<Movies>> childrenVoteMovies;

  const HomeScreen({
    Key? key,
    required this.trendingMovies,
    required this.topRatedMovies,
    required this.grossingMovies,
    required this.childrenMovies,
    required this.actionChildrenMovies,
    required this.romanticChildrenMovies,
    required this.trendingWeekMovies,
    required this.childrenVoteMovies,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String trendingTimeFilter = 'day';
  String trendingTimeChildrenFilter = 'Revenue';
  bool isChildrenFriendly = false;
  
  int currentIndex = 1;
  @override
  void initState() {
    super.initState();
    
    
  }
  void navigateToGridScreen(String movieType) {
  // Navigate to the grid screen with the specified movie type
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MoviesGridScreen(movieType: movieType),
    ),
  );
}

Future<List<Movies>> fetchTrendingMovies() {
    if (trendingTimeFilter == 'day') {
      return widget.trendingMovies;
    } else {
      return widget.trendingWeekMovies; 
    }
  }

  Future<List<Movies>> fetchChildrenMovies() {
    if (trendingTimeChildrenFilter == 'Revenue') {
      return widget.childrenMovies;
    } else {
      return widget.childrenVoteMovies; 
    }
  }


  Future<void> saveLoginStatusToSharedPreferences(bool isLoggedIn) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('login_status', isLoggedIn);
}

Future<String> getUserIDFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_id') ?? 'h9cF4PP4oHKqwfLqgaaV';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/movieblitzlogo.png',
          fit: BoxFit.cover,
          height: 40,
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.search),
        //     onPressed: () {
        //       // Navigate to the search screen here
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => SearchPage()),
        //       );
        //     },
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.people),
        //     onPressed: () {
        //       // Navigate to the actor comparison screen here
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => ActorComparisonPage()),
        //       );
        //     },
        //   ),
        // ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('My List'),
              onTap: () async {
                String currentUserID = await getUserIDFromSharedPreferences();
                
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WatchedMovies(userId:currentUserID)),
              );
              },
            ),
            ListTile(
              title: Text('Watch List'),
              onTap: () async {
                String currentUserID = await getUserIDFromSharedPreferences();
                
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WatchListMovies(userId:currentUserID)),
              );
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                saveLoginStatusToSharedPreferences(false);
                Navigator.pushNamed(context, "/login");
              },
            ),
            
          ],
        ),
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
              Row(
                children: [
                  
                    TrendingTimeButton(
                      label: 'Day',
                      isSelected: trendingTimeFilter == 'day',
                      onTap: () {
                        setState(() {
                          trendingTimeFilter = 'day';
                          // Handle the logic for changing the URL for 'Day'
                          // Call the method or set the variable for the new URL
                        });
                      },
                    
                  ),
                  
                     TrendingTimeButton(
                      label: 'Week',
                      isSelected: trendingTimeFilter == 'week',
                      onTap: () {
                        setState(() {
                          trendingTimeFilter = 'week';
                          // Handle the logic for changing the URL for 'Week'
                          // Call the method or set the variable for the new URL
                        });
                      },
                    ),
                  
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                child: FutureBuilder(
                  future: fetchTrendingMovies(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => navigateToGridScreen('Top Rated'),
                    child: Text('See All',style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => navigateToGridScreen('Grossing'),
                    child: Text('See All',style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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
              Row(
                children: [
                  
                    TrendingTimeButton(
                      label: 'Revenue',
                      isSelected: trendingTimeChildrenFilter == 'Revenue',
                      onTap: () {
                        setState(() {
                          trendingTimeChildrenFilter = 'Revenue';
                        });
                      },
                    
                  ),
                  
                     TrendingTimeButton(
                      label: 'Vote Avg',
                      isSelected: trendingTimeChildrenFilter == 'Vote Avg',
                      onTap: () {
                        setState(() {
                          trendingTimeChildrenFilter = 'Vote Avg';
                          
                        });
                      },
                    ),
                  
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                child: FutureBuilder(
                  future: fetchChildrenMovies(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => navigateToGridScreen('Action Animation'),
                    child: Text('See All',style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => navigateToGridScreen('Romantic Animation'),
                    child: Text('See All',style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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
              // Text(
              //   'Watched Movies',
              //   style: GoogleFonts.aBeeZee(
              //     fontSize: 25,
              //   ),
              // ),
              const SizedBox(height: 32),
              FutureBuilder<String>(
                future: getUserIDFromSharedPreferences(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      // Handle error
                      return Text('Error: ${snapshot.error}');
                    }
                    // Successfully retrieved user ID
                    print(snapshot.data);
                    
                    return WatchedMoviesWidget(userId: snapshot.data ?? 'h9cF4PP4oHKqwfLqgaaV');
                  } else {
                    // Still loading
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.black, // Set the background color to white
        selectedItemColor: Colors.blue, // Set the selected item color
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          // Add navigation logic based on index
          switch (index) {
            
            case 0:
              // Navigate to Search screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
              break;
            case 1:
              break;
            case 2:
              // Navigate to Actor Comparison screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActorComparisonPage()),
              );
              break;
            
            default:
              break;
          }
        },
        items: [
          
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Matching Actors',
          ),
          
            
        ],
      ),
    );
  }
}


class TrendingTimeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TrendingTimeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}