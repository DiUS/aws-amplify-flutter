import 'dart:async';

import 'package:amplify/bloc/auth_bloc.dart';
import 'package:amplify/common/error_handler.dart';
import 'package:amplify/common/injector.dart';
import 'package:amplify/common/routes.dart';
import 'package:amplify/services/analytics_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'auth_event_handler.dart';

class SignInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authBloc = injector.get<AuthBloc>();
  final _authEventHandler = injector.get<AuthEventHandler>();
  final _analyticsService = injector.get<AnalyticsService>();

  StreamSubscription<AuthEvent> _subscription;

  @override
  void initState() {
    super.initState();

    _authBloc.checkStateAsync();
    _analyticsService.trackPage('sign-in');
  }

  @override
  void dispose() {
    _subscription.cancel();

    super.dispose();
  }

  void _signin(BuildContext context) async {
    _analyticsService.trackAction('sign-in');
    _authBloc.signInAsync(userName: _usernameController.text, password: _passwordController.text);
  }

  Widget _buildSignInForm(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              labelText: 'User name',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'User name is required';
              }

              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(icon: Icon(Icons.lock), labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value.isEmpty) {
                return 'Password is required';
              }

              return null;
            },
          ),
          _SignUpLink(analyticsService: _analyticsService),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                child: Text('Login'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _signin(context);
                  }
                },
              ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign in'),
        ),
        body: StreamBuilder(
            stream: _authBloc.stateStream,
            builder: (context, AsyncSnapshot<AuthEvent> eventSnapshot) {
              _subscription ??=
                  _authBloc.stateStream.listen(_authEventHandler.listener(context), onError: errorHandler(context));

              if ([AuthState.signingIn, AuthState.signedIn].contains(eventSnapshot.data?.state)) {
                return Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(builder: (context) => _buildSignInForm(context)),
              );
            }));
  }
}

class _SignUpLink extends StatelessWidget {
  final AnalyticsService analyticsService;

  _SignUpLink({Key key, @required this.analyticsService}) : super(key: key);

  void _signUp(BuildContext context) {
    analyticsService.trackAction('sign-up');
    Navigator.pushNamed(context, Routes.signUpPage);
  }

  void _enterVerificationCode(BuildContext context) {
    analyticsService.trackAction('enter-verification-code');
    Navigator.pushNamed(context, Routes.confirmSignUpPage);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: RichText(
          text: TextSpan(children: [
        TextSpan(
            style:
                DefaultTextStyle.of(context).style.copyWith(decoration: TextDecoration.underline, color: Colors.blue),
            text: 'Sign up',
            recognizer: TapGestureRecognizer()..onTap = () => _signUp(context)),
        TextSpan(
          style: DefaultTextStyle.of(context).style,
          text: ' or ',
        ),
        TextSpan(
            style:
                DefaultTextStyle.of(context).style.copyWith(decoration: TextDecoration.underline, color: Colors.blue),
            text: 'enter verification code',
            recognizer: TapGestureRecognizer()..onTap = () => _enterVerificationCode(context)),
      ])),
    );
  }
}
