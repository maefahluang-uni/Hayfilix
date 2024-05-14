import 'package:firebase_core/firebase_core.dart';
import 'package:movie_app/firebase_options.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_app/RepeatedFunction/login.dart';
import 'package:movie_app/RepeatedFunction/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/RepeatedFunction/contact.dart';

import 'HomePage/HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  SharedPreferences sp = await SharedPreferences.getInstance();
  String imagepath = sp.getString('imagepath') ?? '';
  runApp(MyApp(
    imagepath: imagepath,
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //     overlays: [SystemUiOverlay.bottom]);
}

class MyApp extends StatelessWidget {
  String imagepath;
  MyApp({
    super.key,
    required this.imagepath,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hayfilix',
      home: LoginPage(),
      routes: {
        '/load': (context) => const intermediatescreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/contact': (context) => const ContactUsPage(),
      },
    );
  }
}

class intermediatescreen extends StatefulWidget {
  const intermediatescreen({super.key});

  @override
  State<intermediatescreen> createState() => _intermediatescreenState();
}

class _intermediatescreenState extends State<intermediatescreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      // disableNavigation: true,
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      duration: 2000,
      nextScreen: MyHomePage(),
      splash: Container(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('asset/Icon.png'),
                          fit: BoxFit.contain)),
                ),
              ),  
              // Expanded(
              //   child: Container(
              //     child: Text(
              //       'By Powerpuff Hall',
              //       style: TextStyle(
              //         color: const Color.fromARGB(255, 30, 30, 30),
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      // splash: Image.asset('assets/images/background.jpg'),
      splashTransition: SplashTransition.fadeTransition,
      splashIconSize: 200,
      // centered: false,
    );
  }
}