import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/get_time_string.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class AppInfo {
  static late String appName;
  static late String appVersion;
  static late String packageName;
  static late String? installerStore;
  static late String installationTime;
  static bool isAppInitializedNow = false;

  static Future<void> initializeApp() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    appVersion = packageInfo.version;
    packageName = packageInfo.packageName;
    installerStore = packageInfo.installerStore;

    final appInfo = await SqlDatabase.getAppInfo();
    if (appInfo.isEmpty) {
      final updateInfo = {
        "installation_time": GetTimeString.now,
        "appVersion": packageInfo.version,
      };
      await SqlDatabase.updateAppInfo(updateInfo);
      appInfo.addAll(updateInfo);
      isAppInitializedNow = true;
    }
    installationTime = appInfo["installation_time"]!;
  }
}
