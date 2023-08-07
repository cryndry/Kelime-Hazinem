import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/main.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/disable_battery_opt.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class Notifications {
  static late final String _timeZone;
  static const int _dailyWordChannelId = 1;
  static const String _dailyWordChannelKey = "word_daily";
  static const String _dailyWordChannelName = "Günün Kelimesi";
  static const String _dailyWordChannelDescription = "Her gün bir yeni kelime";
  static const String _wordNotificationGroupKey = "word_group";
  static const String _wordNotificationGroupName = "Yepyeni Kelimeler";

  static Future<void> initService() async {
    _timeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: _wordNotificationGroupKey,
          channelKey: _dailyWordChannelKey,
          channelName: _dailyWordChannelName,
          channelDescription: _dailyWordChannelDescription,
          importance: NotificationImportance.Max,
          defaultColor: MyColors.darkBlue,
          playSound: false,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: _wordNotificationGroupKey,
          channelGroupName: _wordNotificationGroupName,
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    );
  }

  static Future<bool> isNotificationAllowed() async {
    return AwesomeNotifications().isNotificationAllowed();
  }

  static Future<bool> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications(permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Badge,
        NotificationPermission.Light,
        NotificationPermission.Sound,
        NotificationPermission.Vibration,
        NotificationPermission.PreciseAlarms,
        NotificationPermission.FullScreenIntent,
      ]);
      isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (isAllowed) requestDisablingBatteryOptimization();
    }
    return isAllowed;
  }

  static Future<void> createDailyWordNotification(String time) async {
    final notifications = await AwesomeNotifications().listScheduledNotifications();
    final List<NotificationModel> dailyWordNotification = notifications.isNotEmpty
        ? notifications.where((notification) => notification.content?.channelKey == _dailyWordChannelKey).toList()
        : [];
    final dailyWordNotificationSchedule = dailyWordNotification.firstOrNull?.schedule;
    if (dailyWordNotificationSchedule != null) {
      final previousScheduleTime = scheduleToString(dailyWordNotificationSchedule);
      if (previousScheduleTime == time) return;
    }

    late Word word;
    await SqlDatabase.execTempOperation(action: (db) async {
      word = await SqlDatabase.getRandomWord();
    });

    AwesomeNotifications().cancel(_dailyWordChannelId);
    final newSchedule = stringToTimeOfDay(time);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _dailyWordChannelId,
        wakeUpScreen: true,
        showWhen: false,
        channelKey: _dailyWordChannelKey,
        title: _dailyWordChannelName,
        body: """
          <big><b>${word.word}</b></big>
          <br>
          (<small>${word.description}</small>)
          <br>
          ${word.meaning}
        """,
        actionType: ActionType.Default,
        notificationLayout: NotificationLayout.BigText,
        payload: {"word": json.encode(word.toJson())},
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        hour: newSchedule.hour,
        minute: newSchedule.minute,
        repeats: false,
        preciseAlarm: true,
        allowWhileIdle: true,
        timeZone: _timeZone,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "willLearn",
          label: "Öğreneceklerime Ekle",
          actionType: ActionType.SilentBackgroundAction,
          color: MyColors.darkBlue,
        ),
        NotificationActionButton(
          key: "favorite",
          label: "Favorilerime Ekle",
          actionType: ActionType.SilentBackgroundAction,
          color: MyColors.amber,
        ),
      ],
    );
  }

  static String timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    return "$hour:$minute";
  }

  static TimeOfDay stringToTimeOfDay(String time) {
    final hourAndMinute = time.split(":").map((value) => int.parse(value)).toList();
    return TimeOfDay(hour: hourAndMinute[0], minute: hourAndMinute[1]);
  }

  static TimeOfDay scheduleToTimeOfDay(NotificationSchedule schedule) {
    final scheduleAsMap = schedule.toMap();
    final hour = scheduleAsMap["hour"] as int;
    final minute = scheduleAsMap["minute"] as int;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String scheduleToString(NotificationSchedule schedule) {
    final scheduleAsMap = schedule.toMap();
    final hour = scheduleAsMap["hour"].toString().padLeft(2, "0");
    final minute = scheduleAsMap["minute"].toString().padLeft(2, "0");
    return "$hour:$minute";
  }
}

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
