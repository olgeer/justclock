
import 'package:logging/logging.dart';

final logger = Logger('JustClock');
void initLogger(){
  logger.onRecord.listen((event) {
    print("${DateTime.now().toString()} - [${event.loggerName}] - ${event.level.toString()}: ${event.message}");
  });
}