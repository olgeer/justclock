import 'package:fluttertoast/fluttertoast.dart';
import 'package:log_4_dart_2/log_4_dart_2.dart';

void showToast(String msg,
    {int showInSec = 2,
    ToastGravity gravity = ToastGravity.BOTTOM,
    double fontSize = 16.0,
    bool debugMode = true}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: gravity,
    timeInSecForIosWeb: showInSec,
    fontSize: fontSize,
//      backgroundColor: Colors.white,
//      textColor: Colors.black
  );
  if (debugMode) Logger().debug("Toast", msg);
}
