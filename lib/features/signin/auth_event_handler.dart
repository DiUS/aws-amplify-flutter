import 'package:amplify/bloc/auth_bloc.dart';
import 'package:amplify/common/routes.dart';
import 'package:flutter/material.dart';

class AuthEventHandler {
  Function(Object) errorHandler(BuildContext context) {
    return (Object error) => Scaffold.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Function(AuthEvent event) listener(BuildContext context) {
    return (AuthEvent event) {
      if (!ModalRoute.of(context).isCurrent) return;

      switch (event.state) {
        case AuthState.signedIn:
          _openGalleryPage(context);
          break;
        case AuthState.confirmSignUp:
          Navigator.pushReplacementNamed(context, Routes.confirmSignUpPage,
              arguments: event.userName);
          break;
        case AuthState.signUpConfirmed:
          Navigator.pop(context);
          break;
        case AuthState.signedOut:
          Navigator.popAndPushNamed(context, Routes.signInPage);
          break;

        default:
        // do nothing
      }
    };
  }

  void _openGalleryPage(BuildContext context) =>
      Navigator.pushReplacementNamed(context, Routes.galleryPage);
}
