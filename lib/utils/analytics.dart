import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kelime_hazinem/utils/get_time_string.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract final class AnalyticEvents {
  static const String routeChange = "route_change";
  static const String wordAction = "word_action";
  static const String learnModeAction = "learn_mode_action";
  static const String listShare = "list_share";
  static const String keyValueDbChange = "key_value_db_change";
  static const String randomWordCardRefresh = "random_word_card_refreshed";
}

class Analytics {
  static final _analytics = FirebaseAnalytics.instance;

  static Future<void> initService() async {
    final appVersion = (await PackageInfo.fromPlatform()).version;
    await _analytics.setDefaultEventParameters({
      "app_version": appVersion,
      "event_creation_time": GetTimeString.now,
    });
  }

  static Future<void> logRouteChange(String routeName) async {
    return await _analytics.logEvent(
      name: AnalyticEvents.routeChange,
      parameters: {'route_name': routeName},
    );
  }

  static Future<void> logWordAction({required String word, required String action}) async {
    return await _analytics.logEvent(
      name: AnalyticEvents.wordAction,
      parameters: {'word_action_word': word, 'word_action_type': action},
    );
  }

  static Future<void> logLearnModeAction(
      {required String mode, required String listName, required String action}) async {
    return await _analytics.logEvent(
      name: AnalyticEvents.learnModeAction,
      parameters: {'learn_mode': mode, 'learn_mode_list_name': listName, 'learn_mode_action_type': action},
    );
  }

  static Future<void> logListShare({required String code, required String action}) async {
    return await _analytics.logEvent(
      name: AnalyticEvents.listShare,
      parameters: {'list_share_code': code, 'list_share_action_type': action},
    );
  }

  static Future<void> logKeyValueDbChange({required String key, required Object value}) async {
    return await _analytics.logEvent(
      name: AnalyticEvents.keyValueDbChange,
      parameters: {'db_key': key, 'db_value': value.toString()},
    );
  }

  static Future<void> logEventWithoutParams(String eventName) async {
    return await _analytics.logEvent(name: eventName);
  }
}
