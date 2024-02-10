import 'package:flutter/material.dart';
import 'package:movie_app/screens/all_movies_screen.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/details_screen.dart';

class MoviesSlider extends StatelessWidget {
  const MoviesSlider({
    super.key,required this.snapshot,required this.movieType,
  });

  final AsyncSnapshot snapshot;
  final String movieType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:200,
      width:double.infinity,
      child:ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: snapshot.data.length + 1,
        itemBuilder: (context, index) {
          if (index == snapshot.data.length) {
            // Last item in the list, display "See All Movies" button
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the MoviesGridScreen when the button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoviesGridScreen(movieType: movieType),
                    ),
                  );
                },
                child: Text('See All Movies'),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                  onTap: () async {
                    final Movies selectedMovie = snapshot.data[index];
                    //print('Selected Movie ID: ${selectedMovie.movieID}');
                    try {
                      await selectedMovie.fetchCredits(selectedMovie.movieID!);
                      //print('Fetched credits successfully');
                    } catch (e) {
                    //print('Error fetching credits: $e');
                    }
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(movie: selectedMovie),
                      ),
                    );
                  },

              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                  
                child: SizedBox(
                  
                  height:200,
                  width:150,
                  child:Image.network(
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                    '${Constants.imageBaseUrl}${snapshot.data![index].posterPath}',
              
                  ),
                  
                
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}