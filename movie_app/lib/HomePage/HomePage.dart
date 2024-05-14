import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/DetailScreen/checker.dart';
import 'package:movie_app/RepeatedFunction/repttext.dart';
import 'package:movie_app/RepeatedFunction/searchbarfunc.dart';
import 'package:movie_app/apikey/apikey.dart';

import '../RepeatedFunction/Drawer.dart';
import '../SectionHomeUi/movie.dart';
import '../SectionHomeUi/tvseries.dart';
import '../SectionHomeUi/upcomming.dart';

import 'package:dartx/dartx.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // List<Map<String, dynamic>> trendingweek = [];
  // int uval = 1;
  // Future<void> trendinglist(int checkerno) async {
  //   if (checkerno == 1) {
  //     var trendingweekurl =
  //         'https://api.themoviedb.org/3/trending/all/week?api_key=$apikey';
  //     var trendingweekresponse = await http.get(Uri.parse(trendingweekurl));
  //     if (trendingweekresponse.statusCode == 200) {
  //       var tempdata = jsonDecode(trendingweekresponse.body);
  //       var trendingweekjson = tempdata['results'];
  //       for (var i = 0; i < trendingweekjson.length; i++) {
  //         trendingweek.add({
  //           'id': trendingweekjson[i]['id'],
  //           'poster_path': trendingweekjson[i]['poster_path'],
  //           'vote_average': trendingweekjson[i]['vote_average'],
  //           'media_type': trendingweekjson[i]['media_type'],
  //           'indexno': i,
  //         });
  //       }
  //     }
  //   } else if (checkerno == 2) {
  //     var trendingweekurl =
  //         'https://api.themoviedb.org/3/trending/all/day?api_key=$apikey';
  //     var trendingweekresponse = await http.get(Uri.parse(trendingweekurl));
  //     if (trendingweekresponse.statusCode == 200) {
  //       var tempdata = jsonDecode(trendingweekresponse.body);
  //       var trendingweekjson = tempdata['results'];
  //       for (var i = 0; i < trendingweekjson.length; i++) {
  //         trendingweek.add({
  //           'id': trendingweekjson[i]['id'],
  //           'poster_path': trendingweekjson[i]['poster_path'],
  //           'vote_average': trendingweekjson[i]['vote_average'],
  //           'media_type': trendingweekjson[i]['media_type'],
  //           'indexno': i,
  //         });
  //       }
  //     }
  //   }
  //   // print(trendingweek);
  // }

  // 10 list
  int AD_LIST_MAX = 10;
  List<dynamic> advertiseList = [];
  Future<void> advertisement() async {
    var response = await http.get(Uri.parse(
        'https://us-central1-mini-e9d02.cloudfunctions.net/api/get-ad?amount=$AD_LIST_MAX'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      advertiseList = data;
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 3, vsync: this);

    return Scaffold(
        drawer: drawerfunc(),
        backgroundColor: Color.fromRGBO(0, 0, 0, 1),
        body: CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
          SliverAppBar(
              backgroundColor: Color.fromRGBO(220, 0, 0, 1),
              title: //switch between the trending this week and trending today
                  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Trending' + ' 🔥',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16)),
                  SizedBox(width: 10),
                  Container(
                    height: 45,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(6)),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      // child: DropdownButton(
                      //   autofocus: true,
                      //   underline:
                      //       Container(height: 0, color: Color.fromRGBO(255, 255, 255, 1)),
                      //   dropdownColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6),
                      //   icon: Icon(
                      //     Icons.arrow_drop_down_sharp,
                      //     color: Color.fromARGB(255, 227, 15, 15),
                      //     size: 30,
                      //   ),
                      //   value: uval,
                      //   items: [
                      //     // DropdownMenuItem(
                      //     //   child: Text(
                      //     //     '',
                      //     //     style: TextStyle(
                      //     //       decoration: TextDecoration.none,
                      //     //       color: Colors.white,
                      //     //       fontSize: 16,
                      //     //     ),
                      //     //   ),
                      //     //   value: 1,
                      //     // ),
                      //     // DropdownMenuItem(
                      //     //   child: Text(
                      //     //     'Daily',
                      //     //     style: TextStyle(
                      //     //       decoration: TextDecoration.none,
                      //     //       color: Colors.white,
                      //     //       fontSize: 16,
                      //     //     ),
                      //     //   ),
                      //     //   value: 2,
                      //     // ),
                      //   ],
                      //   onChanged: (value) {
                      //     setState(() {
                      //       trendingweek.clear();
                      //       uval = int.parse(value.toString());
                      //       // trendinglist(uval);
                      //     });
                      //   },
                      // ),
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              // automaticallyImplyLeading: false,
              toolbarHeight: 60,
              pinned: true,
              expandedHeight:
                  MediaQuery.of(context).size.height * 0.25, // AD CHANGE SIZE
              actions: [
                // IconButton(icon: Icon(Icons.favorite), onPressed: () {}),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: FutureBuilder(
                  future: advertisement(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CarouselSlider(
                        options: CarouselOptions(
                            viewportFraction: 1,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 2),
                            height: MediaQuery.of(context).size.height * 0.25),
                        items: advertiseList.map((i) {
                          return Builder(builder: (BuildContext context) {
                            return GestureDetector(
                                onTap: () {},
                                child: GestureDetector(
                                    onTap: () {
                                      _launchURL('${i['ad_link']}');
                                    },
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            // color: Colors.amber,
                                            image: DecorationImage(
                                                colorFilter: ColorFilter.mode(
                                                    Color.fromARGB(
                                                            255, 14, 14, 14)
                                                        .withOpacity(0.3),
                                                    BlendMode.darken),
                                                image: NetworkImage(
                                                    '${i['ad_image']}'),
                                                fit: BoxFit.cover)),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // // AD LINK
                                                    // Container(
                                                    //   child: Text(
                                                    //     '', // '${i['ad_link']}',
                                                    //     style: TextStyle(
                                                    //         color: Colors.amber
                                                    //             .withOpacity(
                                                    //                 0.7),
                                                    //         fontSize: 18),
                                                    //   ),
                                                    //   margin: EdgeInsets.only(
                                                    //       left: 10, bottom: 6),
                                                    // ),
                                                    // RATING
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            left: 10,
                                                            right: 8,
                                                            bottom: 14),
                                                        width: 120,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                            color: const Color
                                                                    .fromARGB(
                                                                    255, 0, 0, 0)
                                                                .withOpacity(
                                                                    0.5),
                                                            borderRadius: BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Flexible(
                                                                // Use Flexible to allow the text to determine the width
                                                                child:
                                                                    Container(
                                                                        constraints: BoxConstraints(
                                                                            minWidth:
                                                                                0,
                                                                            maxWidth:
                                                                                1024), // Adjust maxWidth as needed
                                                                        child: Text(
                                                                            '${i['ad_tag']}',
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontWeight: FontWeight.w400))),
                                                              ),
                                                              // Text(
                                                              //     '${i['ad_tag']}',
                                                              //     style: TextStyle(
                                                              //         color: Colors
                                                              //             .white,
                                                              //         fontWeight:
                                                              //             FontWeight
                                                              //                 .w400))
                                                            ]))
                                                  ])
                                            ]))));
                          });
                        }).toList(),
                      );
                    } else {
                      return Center(
                          child: CircularProgressIndicator(
                        color: Colors.amber,
                      ));
                    }
                  },
                ),
              )),
          //////////////////////////////////////////////End of Flexible bar///////////////////////////////////////////////////////////////
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(height: 22),
            Center(
              child: Text(
                'Line ID (for AD): @powerpuff',
                style: GoogleFonts.getFont(
                  'Taviraj', // Specify the Google Font name
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(204, 255, 255, 255),
                  ),
                ),
              ),
            ),
            searchbarfun(),
            Container(
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: TabBar(
                    physics: BouncingScrollPhysics(),
                    labelPadding: EdgeInsets.symmetric(horizontal: 25),
                    isScrollable: true,
                    controller: _tabController,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color:
                            Color.fromARGB(255, 221, 69, 69).withOpacity(0.4)),
                    tabs: [
                      Tab(child: Tabbartext('Tv Series')),
                      Tab(child: Tabbartext('Movies')),
                      Tab(child: Tabbartext('Upcoming'))
                    ])),
            Container(
                height: 1100,
                width: MediaQuery.of(context).size.width,
                child: TabBarView(controller: _tabController, children: const [
                  TvSeries(),
                  Movie(),
                  Upcomming(),
                ]))
          ]))
        ]));
  }
}
