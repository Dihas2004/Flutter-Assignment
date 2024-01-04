import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/colors.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/widgets/back_button.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({
    super.key,
    required this.movie,
  
});
  final Movies movie;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers:[
          SliverAppBar.large(
            leading: const backButton(),
            backgroundColor: Colours.scaffoldBgColor,
            expandedHeight: 500,
            pinned:true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
              movie.title ?? 'Unnamed Movie',
              style:GoogleFonts.belleza(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                
                ),
              ),
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.network(
                  '${Constants.imageBaseUrl}${movie.backdropPath}',
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:Padding(
              padding:EdgeInsets.all(12),
              child:Column(children: [
                Text('Overview',
                style:GoogleFonts.openSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16,),
                Text(movie.description,
                style:GoogleFonts.roboto(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                  ),
                  //textAlign: TextAlign.justify,
                ),
                const SizedBox(height:16),
                SizedBox(
                  child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color:Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:Row(children: [
                      Text('Release Year: ',
                      style:GoogleFonts.roboto(
                        
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        ),  
                      ),
                      Text(
                        movie.movieReleaseYear.toString(),
                        style:GoogleFonts.roboto(
                        
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          ),  
                        ),
                      ],
                    ),
                    
                  ),
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                      border: Border.all(color:Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      ),
                      child:Row(
                        children: [
                        Text(
                          'Rating: ',
                          style:GoogleFonts.roboto(
                        
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        Text(
                          '${movie.voteAvg?.toStringAsFixed(1)}/10'
                        ),
                      ],
                      
                      ),
                  ),

                  ],
                  ),
                
                ),

              ],
              ),
            ),
          ),
        ] ,
      ),
      );
  }
}

