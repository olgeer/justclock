import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:basic_utils/basic_utils.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:cron/cron.dart';
import 'package:hash/hash.dart' as hash;
import 'package:http/http.dart';
import 'package:install_apk_plugin/install_apk_plugin.dart';
import 'package:justclock/pkg/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef eventCall = void Function(dynamic value);

String genKey({int lenght = 24}) {
  const randomChars = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F'
  ];
  String key = "";
  for (int i = 0; i < lenght; i++) {
    key += randomChars[Random().nextInt(randomChars.length)];
  }
  return key;
}

String str2hex(String str) {
  const hex2char = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F'
  ];
  String hexStr = "";
  if (str != null) {
    for (int i = 0; i < str.length; i++) {
      int ch = str.codeUnitAt(i);
      hexStr += hex2char[(ch & 0xF0) >> 4];
      hexStr += hex2char[ch & 0x0F];
//      logger.fine("hexStr:[$hexStr]");
    }
  } else {
    throw new Exception("Param string is null");
  }
  return hexStr;
}

String Uint8List2HexStr(Uint8List uint8list) {
  const hex2char = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F'
  ];
  String hexStr = "";
  if (uint8list != null) {
    for (int i in uint8list) {
      hexStr += hex2char[(i & 0xF0) >> 4];
      hexStr += hex2char[i & 0x0F];
    }
  } else {
    throw new Exception("Param Uint8List is null");
  }
  return hexStr;
}

String size2human(double size) {
  String unit;
  double s = size;
  if (size != -1) {
    int l;
    if (size < 1024) {
      l = 0;
    } else if (size < 1024 * 1024) {
      l = 1;
      s = size / 1024;
    } else {
      for (l = 2; size >= 1024 * 1024; l++) {
        size = size / 1024;
        if ((size / 1024) < 1024) {
          s = size / 1024;
          break;
        }
      }
    }

    switch (l) {
      case 0:
        unit = "Byte";
        break;
      case 1:
        unit = "KB";
        break;
      case 2:
        unit = "MB";
        break;
      case 3:
        unit = "GB";
        break;
      case 4:
        //不可能也不该达到的值
        unit = "TB";
        break;
      default:
        //ER代表错误
        unit = "ER";
    }

    String format = s.toStringAsFixed(1);
    return format + unit;
  }
  return null;
}

String getFileName(String path) {
  // var paths = path.split("/");
  // return paths[paths.length - 1];
  return p.basenameWithoutExtension(path);
}

String getFullFileName(String path) {
  return p.basename(path);
}

String getFileExtname(String path) {
  // var paths = path.split("/");
  // var filenames = paths[paths.length - 1].split(".");
  // return filenames[filenames.length - 1];
  return p.extension(path);
}

String readFileString(String filepath) {
  File readFile = File(filepath);
  if (readFile.existsSync()) {
    return readFile.readAsStringSync(encoding: Utf8Codec());
  }
  return null;
}

void writeFileString(String filepath, String contents) async {
  File writeFile = await File(filepath);
  if (!writeFile.existsSync()) {
    writeFile.createSync(recursive: true);
  }
  writeFile.writeAsStringSync(contents);
  logger.fine( "New file = ${writeFile.path}");
}

String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
String dateTime() => DateTime.now().toString();
int nowInt() => DateTime.now().millisecondsSinceEpoch;

Future<String> sha512(String filePath) async {
  File orgFile = await File(filePath);
  if (!orgFile.existsSync()) return null;

  Uint8List orgBytes = orgFile.readAsBytesSync();
  Uint8List shaBytes = hash.SHA512().update(orgBytes).digest();
  // logger.fine("sha512($filePath)=[${shaBytes.toString()}]");
  return Uint8List2HexStr(shaBytes);
}

List<String> objectListToStringList(List<dynamic> listObject) {
  List<String> newListString;
  if(listObject!=null) {
    newListString=[];
    for (dynamic obj in listObject) {
      newListString.add(obj.toString());
    }
  }
  return newListString;
}

String md5(String str) {
  if (str == null) return null;
  Uint8List md5Bytes = hash.MD5().update(str.codeUnits).digest();
  //logger.fine("md5($str)=${md5Bytes}");
  return Uint8List2HexStr(md5Bytes);
}

void largePrint(dynamic msg) {
  String str;
  final int maxPrintLenght = 511;

  if (!(msg is String)) {
    str = msg.toString();
  } else {
    str = msg;
  }

  for (String oneLine in str.split("\n")) {
    while (oneLine.length > maxPrintLenght) {
      print(oneLine.substring(0, maxPrintLenght));
      oneLine = oneLine.substring(maxPrintLenght);
    }
    print(oneLine);
  }
}

void largeDebug(String logTag, dynamic msg) {
  String str;
  final int maxPrintLenght = 511;

  if (!(msg is String)) {
    str = msg.toString();
  } else {
    str = msg;
  }

  for (String oneLine in str.split("\n")) {
    while (oneLine.length > maxPrintLenght) {
      logger.fine( oneLine.substring(0, maxPrintLenght));
      oneLine = oneLine.substring(maxPrintLenght);
    }
    logger.fine( oneLine);
  }
}

String double2percent(double d) =>
    ((d * 10000).floor() / 100).toStringAsFixed(2);

///设置屏幕旋转使能状态
void setRotateMode({bool canRotate = true}) {
  if (canRotate) {
    AutoOrientation.fullAutoMode();
  } else {
    AutoOrientation.portraitUpMode();
  }
  // Logger().debug("NovelReader", "canRotate:$canRotate");
}

Future<Response> getUrlFile(String url,
    {int retry = 3, int seconds = 3,eventCall onSuccess,
      eventCall onError}) async {
  Response tmp;

  do {
    try {
      tmp = await HttpUtils.getForFullResponse(url);
    } catch (e) {
      print("get file error:$e");
      await Future.delayed(Duration(seconds: seconds));
    }
    if (tmp.statusCode==200 && onSuccess != null) onSuccess(tmp);
  } while ((tmp == null || tmp.statusCode != 200) && --retry > 0);

  if (tmp?.statusCode!=200 && onError != null) onError(tmp?.statusCode);
  return tmp?.statusCode == 200 ? tmp : null;
}

Future<String> initPath() async {
  Directory tempDir = Platform.isIOS
      ? await getLibraryDirectory()
      : await getExternalStorageDirectory();
  return tempDir.path;
}

Future<String> saveUrlFile(String url,
    {String saveFileWithoutExt,
    int retry = 3,
    int seconds = 3,
    eventCall onSuccess,
    eventCall onError}) async {
  Response tmpResp = await getUrlFile(url, retry: retry, seconds: seconds);
  largePrint(tmpResp.headers);
  // if(tmpResp!=null && tmpResp.headers['Content-Length']!=null && int.parse(tmpResp.headers['Content-Length'])>0) {
  if (tmpResp.bodyBytes.length > 0) {
    List<String> tmpSpile = url.split("//")[1].split("/");
    String fileExt;
    if (tmpSpile.last.length > 0 && tmpSpile.last.split(".").length > 1) {
      if (saveFileWithoutExt == null || saveFileWithoutExt.length == 0) {
        saveFileWithoutExt =
            (await initPath()) + "/" + tmpSpile.last.split(".")[0];
      }
      fileExt = tmpSpile.last.split(".")[1];
    } else {
      if (saveFileWithoutExt == null || saveFileWithoutExt.length == 0) {
        saveFileWithoutExt = genKey(lenght: 12);
      }
      fileExt = tmpResp.headers['Content-Type'].split("/")[1];
    }

    File urlFile = File("$saveFileWithoutExt.$fileExt");
    if (urlFile.existsSync()) urlFile.deleteSync();
    urlFile.createSync(recursive: true);
    urlFile.writeAsBytesSync(tmpResp.bodyBytes.toList(),
        mode: FileMode.write, flush: true);
    if (onSuccess != null) onSuccess(urlFile.path);
    return urlFile.path;
  }
  if (onError != null) onError(tmpResp.statusCode);
  return null;
}

String save2File(String filePath, String content) {
  File saveFile = File(filePath);

  if (saveFile.existsSync()) saveFile.deleteSync();
  saveFile.createSync(recursive: true);

  saveFile.writeAsStringSync(content,
      mode: FileMode.write, flush: true, encoding: Utf8Codec());
  return saveFile.path;
}

String read4File(String filePath) {
  File readFile = File(filePath);
  if (readFile.existsSync()) {
    try {
      return readFile.readAsStringSync();
    } catch (e) {
      return null;
    }
  } else
    return null;
}

bool fileRename(String beforeName, String afterName) {
  File beforeFile = File(beforeName);
  // logger.fine( "Ready rename\n$beforeName\n to \n$afterName");
  if (beforeFile.existsSync()) {
    beforeFile.renameSync(afterName);
    logger.fine( "Renamed\n$beforeName\n to \n$afterName");
    return true;
  }
  return false;
}

String str2Regexp(String str) {
  final List<String> encode = [
    '.',
    '\\',
    '(',
    ')',
    '[',
    ']',
    '+',
    '*',
    '^',
    '\$',
    '?',
    '{',
    '}',
    '|',
    '-',
  ];
  String tmp = "";

  for (int i = 0; i < str.length; i++) {
    String c = str.substring(i, i + 1);
    for (String s in encode) {
      if (s.compareTo(c) == 0) {
        tmp += '\\';
        break;
      }
    }
    tmp += c;
  }
  // for(String s in encode){
  //   tmp=tmp.replaceAll(s, '\\'+s);
  // }
  return tmp;
}

String fixJsonFormat(String json) {
  return json?.replaceAll("\\", "\\\\");
}

Future installApk(String _apkFilePath, String appId) async {
  if (_apkFilePath.isEmpty) {
    print('make sure the apk file is set');
    return;
  }

  // Map<Permission, PermissionStatus> statuses = await [
  //   Permission.storage,
  // ].request();

  // if (statuses[Permission.storage] == PermissionStatus.granted) {
  InstallPlugin.installApk(_apkFilePath, appId).then((result) {
    print('install apk $result');
  }).catchError((error) {
    print('install apk error: $error');
  });
  // } else {
  //   print('Permission request fail!');
  // }
}

String languageCode2Text(String code) {
  Map<String, String> transMap = {"zh": "中文", "en": "English"};
  return transMap[code];
}

bool isWorkday(DateTime now) {
  if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday)
    return false;
  return true;
}

String int2Str(int value, {int width = 2}) {
  String s = value.toString();
  for (int i = 0; i < (width - s.length); i++) {
    s = "0" + s;
  }
  return s;
}
