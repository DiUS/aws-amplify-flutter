import 'package:amplify/common/injector.dart';
import 'package:amplify/features/gallery/gallery_page.dart';
import 'package:amplify/features/signin/confirm_signup_page.dart';
import 'package:amplify/features/signin/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'common/routes.dart';
import 'features/gallery/image_view_page.dart';
import 'features/signin/signin_page.dart';

void main() {
  setupInjector();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amplify',
      theme: ThemeData(
          primarySwatch: Colors.green, visualDensity: VisualDensity.adaptivePlatformDensity),
      initialRoute: Routes.signInPage,
      routes: {
        Routes.confirmSignUpPage: (context) => ConfirmSignUpPage(),
        Routes.signUpPage: (context) => SignUpPage(),
        Routes.galleryPage: (context) => GalleryPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.signInPage:
            return PageTransition(child: SignInPage(), type: PageTransitionType.fade);
          case Routes.imagePage:
            return PageTransition(child: ImageViewPage(), type: PageTransitionType.fade,  settings: settings);
        }

        return null;
      },
    );
  }
}
