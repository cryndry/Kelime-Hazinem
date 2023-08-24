extension GetTimeString on DateTime {
  static String get now => DateTime.now().toString().split(".")[0];
  static String get oneWeekBefore => DateTime.now().subtract(const Duration(days: 7)).toString().split(".")[0];
  
  static String get oneMonthBefore {
    final now = DateTime.now();
    final oneMonthBefore = now.copyWith(month: now.month - 1);
    return oneMonthBefore.toString().split(".")[0];
  }

  static String get threeMonthsBefore {
    final now = DateTime.now();
    final threeMonthsBefore = now.copyWith(month: now.month - 3);
    return threeMonthsBefore.toString().split(".")[0];
  }
}
