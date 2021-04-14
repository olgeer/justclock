import 'package:cron/cron.dart';

extension MatchExtension on Schedule {
  bool match(DateTime now){
    if (this?.seconds?.contains(now.second) == false) return false;
    if (this?.minutes?.contains(now.minute) == false) return false;
    if (this?.hours?.contains(now.hour) == false) return false;
    if (this?.days?.contains(now.day) == false) return false;
    if (this?.months?.contains(now.month) == false) return false;
    if (this?.weekdays?.contains(now.weekday) == false) return false;
    return true;
  }
}