// import 'dart:developer';
import 'package:logging/logging.dart';
import 'package:console/console.dart';

final Logger logger = Logger('JustClock');
void initLogger({Level logLevel=Level.FINE}){
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
        color="{@magenta}";
        break;
      case 1000:
        color="{@cyan}";
        break;
      case 1200:
      default:
        color="{@yellow}";
        break;
    }
    if(event.level>=logLevel)print(format("${DateTime.now().toString()} - {@blue}[${event.loggerName}]{@end} - $color${event.level.toString()}{@end} : ${event.message}"));
    // log("${DateTime.now().toString()} -- ${event.level.toString()} : ${event.message}",time:DateTime.now(),name: event.loggerName,level: 0);
  });
}

void largeLog(dynamic msg,{Level level=Level.FINER}) {
  String str;
  final int maxPrintLength = 511;

  if (!(msg is String)) {
    str = msg.toString();
  } else {
    str = msg;
  }

  for (String oneLine in str.split("\n")) {
    while (oneLine.length > maxPrintLength) {
      logger.log(level ,oneLine.substring(0, maxPrintLength));
      oneLine = oneLine.substring(maxPrintLength);
    }
    logger.log(level ,oneLine);
  }
}

// final Map<String, Color> _COLORS = {
//   'black': Color(0),
//   'gray': Color(0, bright: true),
//   'dark_red': Color(1),
//   'red': Color(1, bright: true),
//   'green': Color(2),
//   'lime': Color(2, bright: true),
//   'gold': Color(3),
//   'yellow': Color(3, bright: true),
//   'dark_blue': Color(4),
//   'blue': Color(4, bright: true),
//   'magenta': Color(5),
//   'light_magenta': Color(5, bright: true),
//   'cyan': Color(6),
//   'light_cyan': Color(6, bright: true),
//   'light_gray': Color(7),
//   'white': Color(7, bright: true)
// };