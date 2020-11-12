import 'package:amplify/data/models/user.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';

class UserRepo {
  Future<void> confirmSignUpAsync({String userName, String code}) async {
    try {
      await Amplify.Auth.confirmSignUp(username: userName, confirmationCode: code);
    } on AuthError catch (e) {
      throw Exception(_parseError(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User> getCurrentUserAsync() async {
    try {
      final authUser = await Amplify.Auth.getCurrentUser();
      return User(authUser.userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> signInAsync({String userName, String password}) async {
    try {
      await Amplify.Auth.signIn(username: userName, password: password);
    } on AuthError catch (e) {
      throw Exception(_parseError(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signupAsync({String userName, String password, String email, String phoneNo}) async {
    try {
      Map<String, dynamic> userAttributes = {
        "email": email,
        "phone_number": phoneNo,
      };

      await Amplify.Auth.signUp(
          username: userName,
          password: password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));
    } on AuthError catch (e) {
      throw Exception(_parseError(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOutAsync() async {
    await Amplify.Auth.signOut();
  }

  String _parseError(AuthError error) {
    final errors = StringBuffer();
    error.exceptionList.forEach((e) {
      if (e.detail is String) {
        errors.writeln('${e.exception} - ${e.detail}');
      }
    });

    return errors.isEmpty ? error.cause : errors.toString();
  }
}
