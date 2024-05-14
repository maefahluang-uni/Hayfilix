import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

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
                        Contact(),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(32.0),
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: const [
                        Expanded(child: Contact()),
                      ],
                    ),
                  )));
  }
}

class Contact extends StatelessWidget {
  const Contact({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
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
        SizedBox(
          height: 16.0,
        ),
        Text(
          "Contact Us",
          textAlign: TextAlign.center,
          style: isSmallScreen
              ? Theme.of(context).textTheme.headline5
              : Theme.of(context)
                  .textTheme
                  .headline4
                  ?.copyWith(color: Colors.black),
        ),
        SizedBox(
          height: 4.0,
        ),
        Text(
          "Email: 6531503017@lamduan.mfu.ac.th",
          textAlign: TextAlign.center,
          style: isSmallScreen
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.black),
        ),
        Text(
          "Address: Mae Fah Luang University",
          textAlign: TextAlign.center,
          style: isSmallScreen
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.black),
        ),
      ]
    );
  }
}