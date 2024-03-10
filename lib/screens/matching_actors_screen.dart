import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/actor.dart';
import 'package:movie_app/models/movie.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/screens/search.dart';

class ActorComparisonPage extends StatefulWidget {
  @override
  _ActorComparisonPageState createState() => _ActorComparisonPageState();
}

class _ActorComparisonPageState extends State<ActorComparisonPage> {
  TextEditingController actor1Controller = TextEditingController();
  TextEditingController actor2Controller = TextEditingController();
  List<Movies> commonMovies = [];
  int currentIndex = 2;

  Future<List<Movies>> getMoviesByActor(String actorName) async {
  List<Movies> searchResults = [];
  final actorDetails = await getActorDetails(actorName);

  
  int page = 1;
  bool hasMorePages = true;

  while (hasMorePages) {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/discover/movie?with_cast=${actorDetails?.id}&sort_by=release_date.desc&api_key=${Constants.apiKey}&page=$page',
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> movies = data['results'] ?? [];
      searchResults.addAll(movies.map((json) => Movies.fromJson(json)).toList());

      
      if (data['total_pages'] != null && page < data['total_pages']) {
        page++;
      } else {
        hasMorePages = false;
      }
    } else {
      throw Exception('Failed to search movies');
    }
  }

  return searchResults;
}


  Future<Actor?> getActorDetails(String actorName) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/search/person?api_key=${Constants.apiKey}&query=$actorName&page=1',
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> results = data['results'] ?? [];

      if (results.isNotEmpty) {
        return Actor.fromJson({
          'name': results[0]['name'],
          'known_for_department': results[0]['known_for_department'],
          'id': results[0]['id'],
        });
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to get actor details. Status code: ${response.statusCode}');
    }
  }

  void searchCommonMovies() async {
  String actor1Name = actor1Controller.text;
  String actor2Name = actor2Controller.text;

  if (actor1Name.isNotEmpty && actor2Name.isNotEmpty) {
    try {
      
      final actor1Details = await getActorDetails(actor1Name);
      final actor1Movies = await getMoviesByActor(actor1Name);

      
      final actor2Details = await getActorDetails(actor2Name);
      final actor2Movies = await getMoviesByActor(actor2Name);

      
      commonMovies = actor1Movies
          .where((movie1) =>
              actor2Movies.any((movie2) => movie1.movieID == movie2.movieID))
          .toList();

      setState(() {});
    } catch (e) {
      print('Error searching common movies: $e');
    }
  } else {
   
    commonMovies.clear();
    setState(() {});
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actor Comparison'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: actor1Controller,
                    decoration: InputDecoration(labelText: 'Actor 1'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: actor2Controller,
                    decoration: InputDecoration(labelText: 'Actor 2'),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchCommonMovies,
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: commonMovies.isNotEmpty
                  ? ListView.builder(
                      itemCount: commonMovies.length,
                      itemBuilder: (context, index) {
                        return CustomListTile(
                          height: 150,
                          title: Text(
                            commonMovies[index].title!,
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${commonMovies[index].movieReleaseYear.toString()}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          trailing: Text(
                            '${commonMovies[index].voteAvg}',
                            style: TextStyle(
                              color: Color.fromARGB(255, 128, 123, 23),
                            ),
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              commonMovies[index].posterPath != null
                                  ? '${Constants.imageBaseUrl}${commonMovies[index].posterPath!}'
                                  : 'https://cdn.dribbble.com/users/1242216/screenshots/9326781/media/6384fef8088782664310666d3b7d4bf2.png',
                              width: 50,
                              height: double.infinity,
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text('No common movies found'),
                    ),
            ),
          ],
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
              
              Navigator.pushNamed(context, "/home");
              break;
            case 2:
              // Navigate to Actor Comparison screen
              
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



class CustomListTile extends StatelessWidget {
  final Widget? leading; 
  final Text? title; 
  final Text? subtitle; 
  final Function? onTap; 
  
  final Widget? trailing; 
   
  final double? height; 

  
  const CustomListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.onTap,
    
    this.trailing,
    
    required this.height, 
  });

  @override
  Widget build(BuildContext context) {
    return Material( 
      
      child: InkWell( 
        onTap: () => onTap!(), 
        
        child: SizedBox( 
          height: height, 
          child: Row( 
            children: [
              Padding( 
                padding: const EdgeInsets.only(left: 12.0, right: 12.0,top:12,bottom: 12),
                child: leading, 
              ),
              Expanded( 
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Padding(
                    padding: const EdgeInsets.only(left: 2.0, right: 12.0,top:50,bottom: 12),
                    child:title ?? const SizedBox(),
                    ), 
                    const SizedBox(height: 10), 
                    subtitle ?? const SizedBox(), 
                  ],
                ),
              ),
              Padding( 
                padding: const EdgeInsets.all(12.0),
                child: trailing, 
              )
            ],
          ),
        ),
      ),
    );
  }
}