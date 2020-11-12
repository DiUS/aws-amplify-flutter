import 'dart:async';

import 'package:amplify/bloc/auth_bloc.dart';
import 'package:amplify/common/error_handler.dart';
import 'package:amplify/common/injector.dart';
import 'package:amplify/services/analytics_service.dart';
import 'package:flutter/material.dart';

import 'auth_event_handler.dart';

class ConfirmSignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConfirmSignUpPageState();
}

class _ConfirmSignUpPageState extends State<ConfirmSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _userNameController = TextEditingController();
  final _codeController = TextEditingController();

  final _authBloc = injector.get<AuthBloc>();
  final _authEventHandler = injector.get<AuthEventHandler>();
  final _analyticsService = injector.get<AnalyticsService>();

  StreamSubscription<AuthEvent> _subscription;

  @override
  void initState() {
    super.initState();

    _analyticsService.trackPage('confirm-sign-up');
  }

  void _confirmSignUp() async {
    _analyticsService.trackAction('confirm-sign-up');
    _authBloc.confirmSignUpAsync(userName: _userNameController.text, code: _codeController.text);
  }

  @override
  void dispose() {
    _subscription.cancel();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _userNameController.text = ModalRoute.of(context).settings.arguments as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm sign-up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            child: Column(children: [
              Visibility(
                visible: _userNameController.text == '',
                child: TextFormField(
                  controller: _userNameController,
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
              ),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock_clock),
                  labelText: 'Code',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Code is required';
                  }

                  return null;
                },
              ),
              StreamBuilder(
                  stream: _authBloc.stateStream,
                  builder: (context, AsyncSnapshot<AuthEvent> eventSnapshot) {
                    _subscription ??= _authBloc.stateStream
                        .listen(_authEventHandler.listener(context), onError: errorHandler(context));

                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          child: Text('Confirm'),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _confirmSignUp();
                            }
                          },
                        ));
                  })
            ])),
      ),
    );
  }
}
