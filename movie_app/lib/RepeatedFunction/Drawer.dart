import 'package:flutter/material.dart';
import 'package:movie_app/SectionHomeUi/FavoriateList.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/Component/global.dart';

class drawerfunc extends StatefulWidget {
  drawerfunc({
    super.key,
  });

  @override
  State<drawerfunc> createState() => _drawerfuncState();
}

class _drawerfuncState extends State<drawerfunc> {
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sp) {
      // Inside your method or initState() or wherever appropriate
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color.fromRGBO(33, 33, 33, 0.882),
        child: ListView(
          children: [
            DrawerHeader(
              child: Container(
                child: Column(
                  children: [ 
                    CircleAvatar(
                      radius: 44,
                      backgroundImage: AssetImage('asset/Icon.png'),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '${globalEmail}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            listtilefunc('Home', Icons.home, ontap: () {
              // close drawer
            }),
            listtilefunc('Favorite', Icons.favorite, ontap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FavoriateMovies()));
            }),
            listtilefunc('Contact Us', Icons.contact_page, ontap: () {
              Navigator.pushNamed(context, '/contact');
            }),
            listtilefunc('Quit', Icons.exit_to_app_rounded, ontap: () {
              Navigator.pushNamed(context, '/login');
            }),
          ],
        ),
      ),
    );
  }
}

Widget listtilefunc(String title, IconData icon, {Function? ontap}) {
  return GestureDetector(
    onTap: ontap as void Function()?,
    child: ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}
