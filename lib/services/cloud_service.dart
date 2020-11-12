import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

import '../amplifyconfiguration.dart';

class CloudService {
  static final Amplify _amplifyInstance = Amplify();
  bool _isInitialised = false;

  Future<void> initAsync() async {
    if (!_isInitialised) {
      final analyticsPlugin = AmplifyAnalyticsPinpoint();
      final authPlugin = AmplifyAuthCognito();
      final storagePlugin = AmplifyStorageS3();

      _amplifyInstance.addPlugin(
          authPlugins: [authPlugin],
          analyticsPlugins: [analyticsPlugin],
          storagePlugins: [storagePlugin]);

      await _amplifyInstance.configure(amplifyconfig);
      _isInitialised = true;
    }
  }
}
