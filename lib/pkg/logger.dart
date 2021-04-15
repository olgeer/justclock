// import 'dart:developer';
import 'package:logging/logging.dart';
import 'package:console/console.dart';

final logger = Logger('JustClock');
void initLogger(){
  logger.onRecord.listen((event) {
    String color="{@yellow}";
    final String colorEnd="{@end}";
    switch(event.level.value){
      case 0:
      case 300:
      case 400:
      case 500:
        color="{@green}";
        break;
      case 700:
      case 800:
        color="{@blue}";
        break;
      case 900:
        color="{@orange}";
        break;
      case 1000:
        color="{@cyan}";
        break;
      case 1200:
      default:
        color="{@yellow}";
        break;
    }
    print(format("${DateTime.now().toString()} - {@blue}[${event.loggerName}]{@end} - $color${event.level.toString()}{@end} : ${event.message}"));
    // log("${DateTime.now().toString()} -- ${event.level.toString()} : ${event.message}",time:DateTime.now(),name: event.loggerName,level: 0);
  });
}