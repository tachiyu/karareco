import 'package:intl/intl.dart';

class DateManager {
  static DateTime timestampToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  static String getFormattedDateTime(int timestamp) {
    return DateFormat('yyyy-MM-dd hh:mm:ss')
        .format(timestampToDateTime(timestamp));
  }
}
