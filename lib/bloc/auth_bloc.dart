import 'dart:async';

import 'package:amplify/common/injector.dart';
import 'package:amplify/data/models/user.dart';
import 'package:amplify/data/sources/user_repo.dart';
import 'package:amplify/services/cloud_service.dart';

enum AuthState {
  Unauthenticated,
  signingIn,
  signedIn,
  signingUp,
  confirmSignUp,
  signUpConfirmed,
  signedOut
}

class AuthEvent {
  final String userName;
  final AuthState state;

  AuthEvent({this.userName, this.state});
}

class AuthBloc {
  final _userRepo = injector.get<UserRepo>();
  final _stateController = StreamController<AuthEvent>();

  Stream<AuthEvent> _stateStream;

  AuthBloc() {
    _stateStream = _stateController.stream.asBroadcastStream();
  }

  Stream<AuthEvent> get stateStream => _stateStream;

  void dispose() {
    _stateController.close();
  }

  void confirmSignUpAsync({String userName, String code}) async {
    try {
      await _userRepo.confirmSignUpAsync(userName: userName, code: code);
      _stateController.add(AuthEvent(userName: userName, state: AuthState.signUpConfirmed));
    } catch (e) {
      _stateController.addError(e.toString());
    }
  }

  void checkStateAsync() async {
    final cloudService = injector.get<CloudService>();
    await cloudService.initAsync();

    final user = await _getCurrentUserAsync();
    if (user == null) {
      _stateController.add(AuthEvent(state: AuthState.Unauthenticated));
    } else {
      _stateController.add(AuthEvent(state: AuthState.signedIn));
    }
  }

  Future<User> _getCurrentUserAsync() async {
    try {
      return await _userRepo.getCurrentUserAsync();
    } catch (_) {
      return null;
    }
  }

  void signInAsync({String userName, String password}) async {
    try {
      _stateController.add(AuthEvent(userName: userName, state: AuthState.signingIn));

      await _userRepo.signInAsync(userName: userName, password: password);

      _stateController.add(AuthEvent(userName: userName, state: AuthState.signedIn));
    } catch (e) {
      _stateController.addError(e.toString());
    }
  }

  void signupAsync({String userName, String password, String email, String phoneNo}) async {
    try {
      _stateController.add(AuthEvent(userName: userName, state: AuthState.signingUp));

      await _userRepo.signupAsync(
          userName: userName,
          password: password,
          email: email,
          phoneNo: phoneNo);

      _stateController.add(AuthEvent(userName: userName, state: AuthState.confirmSignUp));
    } catch (e) {
      _stateController.addError(e.toString());
    }
  }

  Future<void> signOutAsync() async {
    await _userRepo.signOutAsync();

    _stateController.add(AuthEvent(state: AuthState.signedOut));
    _stateController.add(AuthEvent(state: AuthState.Unauthenticated));
  }
}
