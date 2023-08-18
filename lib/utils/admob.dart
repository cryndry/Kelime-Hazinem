import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract final class AnalyticEvents {
  static const String routeChange = "route_change";
  static const String wordAction = "word_action";
  static const String learnModeAction = "learn_mode_action";
  static const String listShare = "list_share";
  static const String keyValueDbChange = "key_value_db_change";
  static const String randomWordCardRefresh = "random_word_card_refreshed";
}

abstract class AdMob {
  static final _adMob = MobileAds.instance;
  static const _learnModeBannerIdIOS = "ca-app-pub-8406981056412185/6338819938";
  static const _learnModeBannerIdAndroid = "ca-app-pub-8406981056412185/5970336038";
  static BannerAd? _bannerAd;

  /// [loadBannerAd] must be called before this
  static AdWidget? get bannerAdWidget => _bannerAd == null ? null : AdWidget(ad: _bannerAd!);

  static Future<void> initService() async {
    await _adMob.initialize();
  }

  static void _createBannerAd() {
    _bannerAd = _bannerAd ??
        BannerAd(
          size: AdSize.banner,
          adUnitId: Platform.isAndroid ? _learnModeBannerIdAndroid : _learnModeBannerIdIOS,
          listener: const BannerAdListener(),
          request: const AdRequest(
            httpTimeoutMillis: 5000,
            nonPersonalizedAds: false,
          ),
        );
  }

  static Future<void> loadBannerAd() async {
    if (_bannerAd == null) _createBannerAd();
    await _bannerAd!.load();
  }

  static Future<void> disposeBannerAd() async {
    await _bannerAd?.dispose();
    _bannerAd = null;
  }
}
