class TimeFormatterUtil {
  static String formatElapsedTime(Duration duration) {
    // 1. Calculate values from largest units down to smallest units
    int years = (duration.inDays / 365).floor();
    int months = ((duration.inDays % 365) / 30).floor();
    int days = (duration.inDays % 30);
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    // 2. HIGHEST UNIT LOGIC CHECK
    if (years >= 1) return "$years ${years == 1 ? 'Year' : 'Years'}";
    if (months >= 1) return "$months ${months == 1 ? 'Month' : 'Months'}";
    if (days >= 1) return "$days ${days == 1 ? 'Day' : 'Days'}";
    if (hours >= 1) return "$hours ${hours == 1 ? 'Hour' : 'Hours'}";
    if (minutes >= 1) return "$minutes ${minutes == 1 ? 'Minute' : 'Minutes'}";

    // Default Fallback
    return "$seconds ${seconds == 1 ? 'Second' : 'Seconds'}";
  }
}
