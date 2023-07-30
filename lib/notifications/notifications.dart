import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/notifications/notification_controller.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class Notifications {
  static Future<void> initService() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'word_group',
          channelKey: 'word_daily',
          channelName: 'Günlük Kelime',
          channelDescription: 'Her gün bir yeni kelime',
          importance: NotificationImportance.Max,
          defaultColor: MyColors.darkBlue,
          playSound: false,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(channelGroupKey: 'word_group', channelGroupName: 'Yeni Kelimeler'),
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
    }
    return isAllowed;
  }

  static Future<void> createDailyWordNotification(String time) async {
    const dailyWordNotificationId = 1;
    final notifications = await AwesomeNotifications().listScheduledNotifications();
    final List<NotificationModel> dailyWordNotification = notifications.isNotEmpty
        ? notifications.where((notification) => notification.content?.channelKey == "word_daily").toList()
        : [];
    final dailyWordNotificationSchedule = dailyWordNotification.firstOrNull?.schedule;
    if (dailyWordNotificationSchedule != null) {
      final previousScheduleTime = scheduleToString(dailyWordNotificationSchedule);
      if (previousScheduleTime == time) return;
    }

    AwesomeNotifications().cancel(dailyWordNotificationId);
    late Word word;
    final newSchedule = stringToTimeOfDay(time);
    await SqlDatabase.execTempOperation(action: (db) async {
      word = await SqlDatabase.getRandomWord();
    });
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: dailyWordNotificationId,
        wakeUpScreen: true,
        showWhen: false,
        channelKey: "word_daily",
        title: "Günün Kelimesi",
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
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      ),
      actionButtons: [
        NotificationActionButton(
          key: "willLearn",
          label: "Öğreneceklerime Ekle",
          actionType: ActionType.SilentBackgroundAction,
          color: MyColors.darkBlue,
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
