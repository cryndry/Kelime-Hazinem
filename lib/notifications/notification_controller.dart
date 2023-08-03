import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:kelime_hazinem/main.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    final word = Word.fromJson(json.decode(receivedAction.payload!["word"]!));
    switch (receivedAction.buttonKeyPressed) {
      case "willLearn":
        await SqlDatabase.execTempOperation(action: (db) async {
          await word.willLearnToggle(setValue: 1, db: db);
        });
      case "favorite":
        await SqlDatabase.execTempOperation(action: (db) async {
          await word.favoriteToggle(setValue: 1, db: db);
        });
      case "":
        if (receivedAction.actionType == ActionType.Default) {
          KelimeHazinem.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            'WordShow',
            (route) => (route.settings.name == 'MainScreen') || route.isFirst,
            arguments: {"word": word},
          );
        }
        break;
      default:
        break;
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {}
}
