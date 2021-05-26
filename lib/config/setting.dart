import 'dart:convert';
import 'package:justclock/pkg/logger.dart';
import 'package:justclock/widget/Toast.dart';
import 'package:justclock/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:justclock/config/application.dart';
import 'package:justclock/pkg/utils.dart' as f;

class Setting {
  static String configVersion = "1.0";
  static String configDomain = "http://olgeer.3322.org:8888/justclock/setting.json";
  static String apiDomain="http://olgeer.3322.org:8888/justclock/";
  static String androidVersion = "1.0";
  static String androidUpdateLog;
  static String iosVersion = "1.0";
  static String iosUpdateLog;
  static bool isForceUpdate = false;
  static String androidAppUrl;
  static String iosAppUrl;

  static Future loadSetting() async {
    var settingStr =
        f.readFileString("${Application.appRootPath}/setting.json");
    try {
      if (settingStr != null) {
        Map<String, dynamic> setting = json.decode(settingStr);

        fromJson(setting);
        logger.fine("load setting.json success !");
      }
    } catch (e) {
      logger.warning("Setting file is invaild ! [$settingStr]");
      logger.warning(e);
    }finally{
      await loadSettingFromUrl(configDomain);
    }
  }

  static Future loadSettingFromUrl(String url) async {
    bool configModify = false;
    try {
      logger.fine( url);
      logger.fine(url);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> configJson = json.decode(utf8.decode(response.bodyBytes));
        // print(configJson['androidUpdateLog']);

        //config version is change，record at location file
        if (configVersion
                .compareTo(configJson['configVersion'] ?? configVersion) <
            0) {
          configVersion = configJson['configVersion'];
          configModify = true;

          fromJson(configJson);

          saveSetting();
        }
        if (AppVersion.compareTo(androidVersion) < 0) {
          Application.appCanUpgrade = true;
          Application.cache.remove(DefaultSkin);
        }
      } else {
        logger.fine( "Domain response error[${response.statusCode}]");
      }
      //print("Setting is ${Setting()}");
    } catch (e) {
      logger.warning(e);
    }
  }

  @override
  String toString() {
    return toJson();
  }

  static saveSetting() {
    f.save2File("${Application.appRootPath}/setting.json", Setting.toJson());
    showToast("配置保存成功");
  }

  static String toJson() => jsonEncode({
        "configVersion": configVersion,
        "configDomain": configDomain,
        "apiDomain": apiDomain,
        "androidVersion": androidVersion,
        "androidUpdateLog": androidUpdateLog,
        "androidAppUrl": androidAppUrl,
        "iosVersion": iosVersion,
        "iosUpdateLog": iosUpdateLog,
        "iosAppUrl": iosAppUrl,
        "isForceUpdate": isForceUpdate,
      });

  static fromJson(Map<String, dynamic> jmap) {
    configVersion = jmap["configVersion"] ?? configVersion;
    configDomain = jmap["configDomain"] ?? configDomain;
    apiDomain = jmap['apiDomain'] ?? apiDomain;
    androidVersion = jmap['androidVersion'] ?? androidVersion;
    androidUpdateLog = jmap['androidUpdateLog'] ?? androidUpdateLog;
    androidAppUrl = jmap['androidAppUrl'] ?? androidAppUrl;
    iosVersion = jmap['iosVersion'] ?? iosVersion;
    iosUpdateLog = jmap['iosUpdateLog'] ?? iosUpdateLog;
    iosAppUrl = jmap['iosAppUrl'] ?? iosAppUrl;
    isForceUpdate = jmap['isForceUpdate'] ?? false;
  }
}
