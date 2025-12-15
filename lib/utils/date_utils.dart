import 'package:table_calendar/table_calendar.dart';

class DateUtilsHelper {
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, 12);
  }

  static DateTime onlyDate(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  static bool isDayInPast(DateTime selectedDay) {
    final today = onlyDate(DateTime.now());
    final day = onlyDate(selectedDay);
    return day.isBefore(today);
  }

  static DateTime hourStringToDateTime(DateTime day, String hour) {
    final parts = hour.split(' ');
    final time = parts[0];
    final period = parts[1];

    final hm = time.split(':');
    int h = int.parse(hm[0]);
    final int m = int.parse(hm[1]);

    if (period == 'PM' && h != 12) h += 12;
    if (period == 'AM' && h == 12) h = 0;

    return DateTime(day.year, day.month, day.day, h, m);
  }

  static bool isHourInPast(DateTime day, String hour) {
    if (isDayInPast(day)) return true;

    final now = DateTime.now();
    if (!isSameDay(day, now)) return false;

    final hourDate = hourStringToDateTime(day, hour);
    return hourDate.isBefore(now);
  }
}
