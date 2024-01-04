import 'package:flutter/material.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/details_screen.dart';
import 'package:movie_app/models/movie.dart';

class SearchSlider extends StatelessWidget {
  const SearchSlider({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  final AsyncSnapshot<List<Movies>> snapshot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: snapshot.data?.length,
        itemBuilder: (context, index) {
          final List<Movies>? movies = snapshot.data;

          if (movies == null || index >= movies.length) {
            return SizedBox.shrink(); // Return an empty widget if no movie or index is out of bounds
          }

          final Movies movie = movies[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child:GestureDetector(
            onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => DetailsScreen(movie: movie),
            ),
            );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${Constants.imageBaseUrl}${movie.posterPath}',
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                    height: 150, // Adjust the height as needed
                  ),
                ),
                SizedBox(width: 50),
                Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title ?? '',
                      
                      
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${movie.movieReleaseYear}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${movie.voteAvg ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber,
                      ),
                    ),
                    
                  ],
                ),
              ],
            ),
            ),
          );
          
        },
      ),
    );
  }
}
