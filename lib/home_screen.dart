import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/widgets/movies_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:Image.asset(
          'assets/flutflix.png',
          fit:BoxFit.cover,
          height: 40,
          
        ),
        centerTitle: true,

      ),
    
      body:SingleChildScrollView(
        physics:const BouncingScrollPhysics(),
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Text('Trending Movies',
              style: GoogleFonts.aBeeZee(fontSize: 25),
          
              ),
              const SizedBox( height:32),
              SizedBox(
                width: double.infinity,
                child: CarouselSlider.builder(
                  itemCount: 10,
                  options: CarouselOptions(
                    height:300,
                    autoPlay: true,
                    viewportFraction: 0.55,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    pageSnapping: true,
                    autoPlayAnimationDuration: const Duration(seconds:1 ),
          
                  ),
                  itemBuilder:(context,itemIndex,pageViewIndex){
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height:300,
                        width:200,
                        color: Colors.amber,
                      ),
                    );
                  },
                ),
                  
              ),
              const SizedBox(height:32),
              Text(
                'Top Rated Movies',
                style:GoogleFonts.aBeeZee(
                  fontSize: 25,
                  ),
              
              ),
              const SizedBox(height:32),
              const MoviesSlider(),
              
              const SizedBox(height:32),
              Text(
                'Upcoming Movies',
                style:GoogleFonts.aBeeZee(
                  fontSize: 25,
                  ),
              
              ),
              const SizedBox(height:32),
              const MoviesSlider(),
            ],
          ),
        )
        )

    );

  }
}

