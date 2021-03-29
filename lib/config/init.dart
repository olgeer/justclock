
import 'package:justclock/pkg/lamp.dart';
import 'package:justclock/pkg/utils.dart';
import 'package:justclock/config/application.dart';
import 'package:justclock/config/constants.dart';
import 'package:justclock/config/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:justclock/pkg/logger.dart';
import 'package:vibration/vibration.dart';

//App启动前预处理
void preProcess() async {
  Application.appRootPath = await initPath();
  Application.cache = await SharedPreferences.getInstance();

  //获取震动器信息
  if (await Vibration.hasVibrator()) {
    Application.hasVibrator = true;
    if (await Vibration.hasAmplitudeControl()) {
      Application.hasAmplitudeControl = true;
    }
    if (await Vibration.hasCustomVibrationsSupport()) {
      Application.hasCustomVibrationsSupport = true;
    }
  }
  print(
      "hasVibrator=${Application.hasVibrator} hasAmplitudeControl=${Application.hasAmplitudeControl} hasCustomVibrationsSupport=${Application.hasCustomVibrationsSupport}");

  FlashLamp.init();
  FlashLamp.useLamp = Application.cache.getBool(UseLampTag) ?? true;
  Application.useLamp=FlashLamp.useLamp;

  Application.canRotate = Application.cache.getBool(CanRotateTag) ?? false;
  Application.oledAntiBurn =
      Application.cache.getBool(OledAntiBurnTag) ?? false;
  Application.alertAtHour = Application.cache.getBool(AlertAtHourTag) ?? true;
  Application.comfortableGreeting =
      Application.cache.getBool(ComfortableGreetTag) ?? true;
  Application.showIntro = Application.cache.getBool(ShowIntroTag) ?? true;

  initLogger();

  Setting.loadSetting();
  // print(Setting.toJson());

  Application.defaultSkin=Application.cache.getString(DefaultSkin);

  // print(Icons.cancel.fontFamily);
  // print(Icons.cancel.fontPackage);
}


