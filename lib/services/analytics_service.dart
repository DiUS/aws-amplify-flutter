import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_core/amplify_core.dart';

class AnalyticsService {
  String _page;

  void trackPage(String page) async {
    _page = page;

    AnalyticsEvent event = AnalyticsEvent('page.$page');
    Amplify.Analytics.recordEvent(event: event);
  }

  void trackAction(String action) async {
    AnalyticsEvent event = AnalyticsEvent('action.$action');
    event.properties.addStringProperty("page", _page);
    Amplify.Analytics.recordEvent(event: event);
  }
}
