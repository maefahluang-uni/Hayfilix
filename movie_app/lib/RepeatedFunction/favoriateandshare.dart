import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_app/SqfLitelocalstorage/NoteDbHelper.dart';

import 'package:movie_app/Component/global.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Widget addtofavoriate(id, type, Details, context) {}

class addtofavoriate extends StatefulWidget {
  var id, type, Details;
  addtofavoriate({
    this.id,
    this.type,
    this.Details,
  });

  @override
  State<addtofavoriate> createState() => _addtofavoriateState();
}

class _addtofavoriateState extends State<addtofavoriate> {
  Future checkfavoriate() async {
    FavMovielist()
        .search(widget.id.toString(), widget.Details[0]['title'].toString(),
            widget.type)
        .then((value) {
      if (value == 0) {
        print('notanythingfound');
        favoriatecolor = Colors.white;
      } else {
        //print the tmdbname and tmdbid and tmdbtype and tmdbrating from database

        print('surelyfound');
        favoriatecolor = Colors.red;
      }
    });
    await Future.delayed(Duration(milliseconds: 100));
  }

  Color? favoriatecolor;

  addatatbase(
    id,
    name,
    type,
    rating,
    customcolor,
  ) async {
    if (customcolor == Colors.white) {
      FavMovielist().insert({
        'tmdbid': id,
        'tmdbtype': type,
        'tmdbname': name,
        'tmdbrating': rating,
      });
      favoriatecolor = Colors.red;
      Fluttertoast.showToast(
          msg: "Added to Favorite",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);


      //// Addtition Firebase
      var url = 'https://us-central1-mini-e9d02.cloudfunctions.net/api/set-fav';
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({  
        'email': globalEmail,
        'password': globalPassword,
        // inherit
        'tmdbid': id,
        'tmdbtype': type,
        'tmdbname': name,
        'tmdbrating': rating,
      });
      try {
        var response =
            await http.post(Uri.parse(url), headers: headers, body: body);
        if (response.statusCode == 200) {}
      } catch(e) {}
    } else if (customcolor == Colors.red) {
      FavMovielist().deletespecific(id, type);
      favoriatecolor = Colors.white;
      Fluttertoast.showToast(
          msg: "Removed from Favorite",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);


      //// Addtition Firebase
      var url = 'https://us-central1-mini-e9d02.cloudfunctions.net/api/delete-fav';
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({  
        'email': globalEmail,
        'password': globalPassword,
        // inherit
        'tmdbid': id,
      });
      try {
        var response =
            await http.delete(Uri.parse(url), headers: headers, body: body);
        if (response.statusCode == 200) {}
      } catch(e) {}
    }
  }

  @override
  void initState() {
    super.initState();
    checkfavoriate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width / 2,
            child: FutureBuilder(
                future: checkfavoriate(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                      height: 55,
                      margin: EdgeInsets.only(top: 20),
                      padding: EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 50,
                        width: 50,
                        child: IconButton(
                          icon: Icon(Icons.favorite,
                              color: favoriatecolor, size: 30),
                          onPressed: () {
                            print('pressed');
                            setState(() {
                              addatatbase(
                                widget.id.toString(),
                                widget.Details[0]['title'].toString(),
                                widget.type,
                                widget.Details[0]['vote_average'].toString(),
                                favoriatecolor,
                              );
                            });
                          },
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width,
                    );
                  }
                }),
          ),
          
        ]));
  }
}
