import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

class ReviewUI extends StatefulWidget {
  List revdeatils = [];
  ReviewUI({required this.revdeatils});

  @override
  State<ReviewUI> createState() => _ReviewUIState();
}

class _ReviewUIState extends State<ReviewUI> {
  bool showall = false;

  @override
  Widget build(BuildContext context) {
    List REviewDetails = widget.revdeatils;
    if (REviewDetails.length == 0) {
      return Center();
    } else {
      return Column(
        
      );
    }
  }
}

// Widget ReviewUII(context, List REviewDetails) {}
