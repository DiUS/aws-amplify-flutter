import 'dart:async';

import 'package:amplify/bloc/auth_bloc.dart';
import 'package:amplify/common/error_handler.dart';
import 'package:amplify/common/injector.dart';
import 'package:amplify/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'auth_event_handler.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _authBloc = injector.get<AuthBloc>();
  final _authEventHandler = injector.get<AuthEventHandler>();
  final _analyticsService = injector.get<AnalyticsService>();

  StreamSubscription<AuthEvent> _subscription;

  @override
  void initState() {
    super.initState();

    _analyticsService.trackPage('sign-up');
  }

  @override
  void dispose() {
    _subscription.cancel();

    super.dispose();
  }

  void _signup(BuildContext context) async {
    _analyticsService.trackAction('sign-up');
    _authBloc.signupAsync(
        userName: _usernameController.text,
        password: _passwordController.text,
        email: _emailController.text,
        phoneNo: _phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign up'),
        ),
        body: StreamBuilder(
            stream: _authBloc.stateStream,
            builder: (context, AsyncSnapshot<AuthEvent> eventSnapshot) {
              _subscription ??= _authBloc.stateStream
                  .listen(_authEventHandler.listener(context), onError: errorHandler(context));

              if (eventSnapshot.data?.state == AuthState.signingUp) {
                return Center(child: CircularProgressIndicator());
              }

              return _buildSignUpForm();
            }));
  }

  ListView _buildSignUpForm() {
    return ListView(padding: EdgeInsets.all(16.0), children: <Widget>[
      Center(
        child: Column(children: [
          const Padding(padding: EdgeInsets.all(5.0)),
          Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: 'Email address',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Email address is required';
                    }

                    return null;
                  },
                ),
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
                TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.phone),
                      labelText: 'Phone No',
                    )),
                Builder(
                  builder: (context) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        child: Text('Sign up'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _signup(context);
                          }
                        },
                      )),
                )
              ]))
        ]),
      )
    ]);
  }
}
