import 'dart:convert';
import 'dart:io';
import 'package:justclock/config/application.dart';
import 'package:base_utility/toast.dart';
import 'package:base_utility/logger.dart';
import 'package:base_utility/utils.dart';
import 'package:dio/dio.dart';

class Setting {
  static String configVersion = "1.0";
  static String configDomain = "http://olgeer.3322.org:14080/justclock";
  static String? apiLoginDomain, apiUploadDomain;
  static String? apiDomain = "http://olgeer.3322.org:14080/justclock/";
  static String androidVersion = "1.0";
  static String androidUpdateLog="";
  static String iosVersion = "1.0";
  static String iosUpdateLog="";
  static bool isForceUpdate = false;
  static String? androidAppUrl;
  static String? iosAppUrl;
  static late String nsconfigUrl;
  static bool configModify = false;

  static Future loadSetting() async {
    String logId=genKey(lenght: 8);
    // var setting_str = await rootBundle.loadString('assets/setting/setting.json');
    logger.info("loading ${Application.appRootPath}/setting.json");
    var settingStr;
    if(!Application.fouceInit)settingStr=read4File("${Application.appRootPath}/setting.json");
    try {
      if (settingStr != null) {
        Map<String, dynamic> setting = json.decode(settingStr);
        // setting['apiDomain']="http://olgeer.3322.org:8088/api";

        fromJson(setting);
        print("Setting-$logId load setting.temple success !");
      }

    } catch (e) {
      print("Setting-$logId Setting file is invaild ! [$settingStr]");
      print("Setting-$logId ${e.toString()}");
    }finally{
      await loadSettingFromUrl("$configDomain/setting.json");
    }
  }

  static Future loadSettingFromUrl(String url) async {
    String logId=genKey(lenght: 8);
    try {
      print("Setting-$logId $url");
      // var response = await http.get(Uri.parse(url));
      Response? response = await getUrlFile(url);

      if (response?.statusCode == 200) {
        Map<String, dynamic> configJson = json.decode(utf8.decode(response!.data.toList()));
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
        if (Application.appVersion.compareTo(androidVersion) < 0) {
          Application.appCanUpgrade = true;
        }
      } else {
        print("Setting-$logId Domain response error[${response?.statusCode}]");
      }
      //print("Setting is ${Setting()}");
    } catch (e) {
      print("Setting-$logId ${e.toString()}");
    }
  }

  @override
  String toString() {
    return toJson();
  }

  static saveSetting() {
    save2File("${Application.appRootPath}/setting.json", Setting.toJson(),fileMode: FileMode.write);
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
    "nsconfigUrl": nsconfigUrl,
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
    nsconfigUrl = jmap['nsconfigUrl'] ?? nsconfigUrl;
  }
}
