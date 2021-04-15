import 'package:fluttertoast/fluttertoast.dart';
import 'package:justclock/pkg/logger.dart';

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
  if (debugMode)logger.fine(msg);
}
