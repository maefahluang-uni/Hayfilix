import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_app/Component/CustomTextInputFormatter.dart';
// import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:movie_app/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:movie_app/Component/global.dart';
import 'package:movie_app/Component/toast.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: isSmallScreen
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _Logo(),
                        _FormContent(),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(32.0),
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: const [
                        Expanded(child: _Logo()),
                        Expanded(
                          child: Center(child: _FormContent()),
                        ),
                      ],
                    ),
                  )));
  }
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      // backgroundColor: Color.fromRGBO(68, 68, 68, 1),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          // width: double.infinity,
          // height: double.infinity,
          alignment: Alignment.center,
          child: Image.asset(
            'asset/Icon.png',
            // width: 100,
            height: 180,
            fit: BoxFit.cover, // Adjust fit to resize the image
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome to, Hayfilix",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.headline5
                : Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(color: Colors.black),
          ),
        ),
      ],
    );
  }
}



















class _FormContent extends StatefulWidget {
  const _FormContent({Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isSigningIn = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _loginIn() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isSigningIn = true;
      });

      setState(() {
        _isSigningIn = false;
      });
    } else {
      setState(() {
        _isSigningIn = true;
      });

      String email = emailController.text;
      String password = passwordController.text;




      var url = 'https://us-central1-mini-e9d02.cloudfunctions.net/api/profile';
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({  
        'email': email,
        'password': password,
      });
      try {
        var response =
            await http.post(Uri.parse(url), headers: headers, body: body);
        if (response.statusCode == 200) {
          globalEmail = email; // Store email globally
          globalPassword = password; // Store password globally
          Navigator.pushNamed(context, '/load');
        } else if (response.statusCode == 400) {
          showToast(message: "Email is already in use");
        } else {
          showToast(message: "Failed to create user");
        }
      } catch (e) {
        return showToast(message: "Failed ${e.toString()}");
      }






      // // will fix to using API Login.
      // var user = await _auth.signInWithEmailAndPassword(email, password);
      // setState(() {
      //   _isSigningIn = false;
      // });
      // if (user != null) {
      //   print(user);
      //   showToast(message: "Sign in successfully");
      //   globalEmail = email; // Store email globally
      //   globalPassword = password; // Store password globally
      //   Navigator.pushNamed(context, '/load');
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller:  emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                bool emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (!emailValid) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
                // border: OutlineInputBorder(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              inputFormatters: [CustomTextInputFormatter()],
            ),
            _gap(),
            TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  // border: const OutlineInputBorder(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )),
              inputFormatters: [CustomTextInputFormatter()],
            ),
            _gap(),
            CheckboxListTile(
              value: _rememberMe,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _rememberMe = value;
                });
              },
              title: const Text('Remember me'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: const EdgeInsets.all(0),
            ),
            _gap(),
            SizedBox(
              // backgroundColor: Color.fromRGBO(68, 68, 68, 1),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(255, 32, 32, 1),
                  // primary: _isHovered ? Colors.blue.withOpacity(0.8) : Colors.blue,
                  // onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    // backgroundColor: Color.fromRGBO(68, 68, 68, 1),
                    'Sign in',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 255, 255, 1)),
                  ),
                ),
                onPressed: _loginIn,
                // onPressed: () {
                //   if (_formKey.currentState?.validate() ?? false) {
                //     Navigator.pushNamed(context, '/load');
                //   }
                // },
              ),
            ),
            _gap(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 114, 114, 1),
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
