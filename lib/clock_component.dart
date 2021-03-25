import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:colours/colours.dart';
import 'package:justclock/config/application.dart';
import 'package:justclock/config/constants.dart';
import 'package:justclock/config/setting.dart';
import 'package:justclock/pkg/utils.dart';
import 'package:justclock/widget/Toast.dart';
import 'package:justclock/widget/digitalClock.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';

class ClockComponent extends StatefulWidget {
  @override
  ClockComponentState createState() => ClockComponentState();
}

class ClockComponentState extends State<ClockComponent> {
  DigitalClockConfig textClock = DigitalClockConfig(
    "TextClock",
    height: 100,
    width: 200,
    yearItem: ItemConfig(
      style: DateStyle.chinese.index,
      textStyle: TextStyle(fontSize: 9, color: Colors.white),
      rect: Rect.fromCenter(center: Offset(-60, -30), width: 40, height: 10),
    ),
    monthItem: ItemConfig(
      style: DateStyle.chinese.index,
      textStyle: TextStyle(fontSize: 9, color: Colors.white),
      rect: Rect.fromCenter(center: Offset(-20, -30), width: 40, height: 10),
    ),
    dayItem: ItemConfig(
      style: DateStyle.chinese.index,
      textStyle: TextStyle(fontSize: 9, color: Colors.white),
      rect: Rect.fromCenter(center: Offset(20, -30), width: 40, height: 10),
    ),
    weekdayItem: ItemConfig(
      style: DateStyle.chinese.index,
      textStyle: TextStyle(fontSize: 9, color: Colors.white),
      rect: Rect.fromCenter(center: Offset(60, -30), width: 40, height: 10),
    ),
    hourItem: ItemConfig(
      style: TimeStyle.number.index,
      textStyle: TextStyle(fontSize: 50, color: Colours.lightGoldenRodYellow),
      rect: Rect.fromCenter(center: Offset(-33, 0), width: 60, height: 48),
    ),
    minuteItem: ItemConfig(
      style: TimeStyle.number.index,
      textStyle: TextStyle(fontSize: 50, color: Colours.lightGoldenRodYellow),
      rect: Rect.fromCenter(center: Offset(47, 0), width: 60, height: 48),
    ),
    tiktokItem: ItemConfig(
        style: TikTokStyle.text.index,
        textStyle: TextStyle(fontSize: 50, color: Colours.lightGoldenRodYellow),
        rect: Rect.fromCenter(center: Offset(7, 0), width: 14, height: 48)),
    h12Item: ItemConfig(
      style: H12Style.text.index,
      textStyle: TextStyle(fontSize: 9, color: Colours.lightGoldenRodYellow),
      rect: Rect.fromCenter(center: Offset(-73, 17), width: 20, height: 12),
    ),
    settingItem: ItemConfig(
      style: ActionStyle.icon.index,
      rect: Rect.fromCenter(center: Offset(86, -29), width: 14, height: 12),
      imgs: [Icons.settings.codePoint.toString()],
    ),
    exitItem: ItemConfig(
      style: ActionStyle.empty.index,
      rect: Rect.fromCenter(center: Offset(47, 0), width: 60, height: 46),
    ),
    backgroundColor: Colors.black,
    foregroundColor: Colors.greenAccent,
    // backgroundImage: "assets/clock/bg.png",
    // bodyImage: "assets/clock/body.png",
    timeType: TimeType.h12,
  );

  DigitalClockConfig flipClock2 = DigitalClockConfig(
    "DigitalClock",
    height: 360,
    width: 640,
    foregroundColor: Colors.grey,
    backgroundColor: Colors.black,
    backgroundImage: "bg.png",
    bodyImage: ItemConfig(
      style: TikTokStyle.pic.index,
      rect: Rect.fromCenter(center: Offset(0, 0), width: 640, height: 360),
      imgs: ["body2.png"],
    ),
    timeType: TimeType.h12,
    skinBasePath: "DigitalClock",
    hourItem: ItemConfig(
        style: TimeStyle.flip.index,
        rect: Rect.fromCenter(center: Offset(-146, 9), width: 222, height: 239),
        imgPrename: "d",
        imgExtname: ".png"),
    minuteItem: ItemConfig(
        style: TimeStyle.flip.index,
        rect: Rect.fromCenter(center: Offset(93, 9), width: 222, height: 239),
        imgPrename: "d",
        imgExtname: ".png"),
    tiktokItem: ItemConfig(
      style: TikTokStyle.pic.index,
      rect: Rect.fromCenter(center: Offset(238, 100), width: 45, height: 50),
      imgs: ["poweroff.png", "poweron.png"],
    ),
    h12Item: ItemConfig(
      style: H12Style.pic.index,
      rect: Rect.fromCenter(center: Offset(238, -78), width: 45, height: 85),
      imgs: ["am.png", "pm.png"],
    ),
    settingItem: ItemConfig(
      style: ActionStyle.empty.index,
      rect: Rect.fromCenter(center: Offset(238, -78), width: 45, height: 85),
      imgs: null,
    ),
    exitItem: ItemConfig(
      style: H12Style.pic.index,
      rect: Rect.fromCenter(center: Offset(238, 100), width: 45, height: 50),
    ),
  );
  //
  // DigitalClockConfig flipClock = DigitalClockConfig(
  //   "DigitalFlipClock",
  //   height: 360,
  //   width: 640,
  //   foregroundColor: Colors.grey,
  //   backgroundColor: Colors.black,
  //   backgroundImage: "bg.png",
  //   bodyImage: "body2.png",
  //   timeType: TimeType.h12,
  //   skinBasePath: "DigitalFlipClock",
  //   hourItem: ItemConfig(
  //     style: TimeStyle.flip.index,
  //     rect: Rect.fromCenter(center: Offset(-146, 10), width: 210, height: 233),
  //     textStyle: TextStyle(fontSize: 180, color: Colors.white),
  //   ),
  //   minuteItem: ItemConfig(
  //     style: TimeStyle.flip.index,
  //     rect: Rect.fromCenter(center: Offset(93, 10), width: 210, height: 233),
  //     textStyle: TextStyle(fontSize: 180, color: Colors.white),
  //   ),
  //   tiktokItem: ItemConfig(
  //     style: TikTokStyle.pic.index,
  //     rect: Rect.fromCenter(center: Offset(238, 100), width: 45, height: 50),
  //     imgs: ["poweroff.png", "poweron.png"],
  //   ),
  //   h12Item: ItemConfig(
  //     style: H12Style.pic.index,
  //     rect: Rect.fromCenter(center: Offset(238, -78), width: 45, height: 85),
  //     imgs: ["am.png", "pm.png"],
  //   ),
  //   settingItem: ItemConfig(
  //     style: ActionStyle.icon.index,
  //     rect: Rect.fromCenter(center: Offset(230, 20), width: 14, height: 12),
  //     imgs: [Icons.settings.codePoint.toString()],
  //   ),
  //   exitItem: ItemConfig(
  //     style: H12Style.pic.index,
  //     rect: Rect.fromCenter(center: Offset(238, 100), width: 45, height: 50),
  //   ),
  // );

  DigitalClockConfig flipClock3 = DigitalClockConfig(
    "DigitalFlipClock2",
    height: 360,
    width: 640,
    foregroundColor: Colors.grey,
    backgroundColor: Colors.black,
    backgroundImage: null,
    bodyImage: ItemConfig(
      style: H12Style.pic.index,
      rect: Rect.fromCenter(center: Offset(0, 0), width: 461, height: 261),
      imgs: ["body.png"],
    ),
    timeType: TimeType.h12,
    skinBasePath: "DigitalFlipClock2",
    hourItem: ItemConfig(
        style: TimeStyle.flip.index,
        rect: Rect.fromCenter(center: Offset(-119, 1), width: 222, height: 239),
        imgPrename: "d",
        imgExtname: ".png"),
    minuteItem: ItemConfig(
        style: TimeStyle.flip.index,
        rect: Rect.fromCenter(center: Offset(119, 1), width: 222, height: 239),
        imgPrename: "d",
        imgExtname: ".png"),
    tiktokItem: null,
    h12Item: null,
    settingItem: null,
    exitItem: ItemConfig(
      style: H12Style.pic.index,
      rect: Rect.fromCenter(center: Offset(119, 1), width: 222, height: 239),
    ),
  );

  DigitalClockConfig clockConfig;

  @override
  void initState() {
    AutoOrientation.landscapeAutoMode();
    Wakelock.enable();
    checkUpgrade();
    reloadConfig();
    // clockConfig=flipClock2;
    // clockConfig.skinBasePath =
    // "${Application.appRootPath}/skins/${flipClock2.skinBasePath}/";

    // largePrint(textClock);
    // largePrint(flipClock);
    // largePrint(flipClock2);
  }

  void checkUpgrade(){
    Future.delayed(Duration(milliseconds: 2000), () async {
      //强制升级
      if (Application.appCanUpgrade &&
          Setting.androidAppUrl != null &&
          Setting.isForceUpdate && Platform.isAndroid) {
        // showToast(LocaleKeys.launch_forceUpgradeAlert.tr(),showInSec: 15);
        showToast(Setting.androidUpdateLog,showInSec: 15);
        String apkFile = await saveUrlFile(Setting.androidAppUrl);
        Vibration.vibrate();
        await installApk(apkFile, AppId);
      }
    });
  }

  void reloadConfig() {
    if (Application.defaultSkin != null) {
      // Application.defaultSkin="DigitalFlipClock";

      print("load ${Application.defaultSkin} skin");
      File clockConfigFile = File(
          "${Application.appRootPath}/skins/${Application.defaultSkin}/config.json");

      if (clockConfigFile.existsSync()) {
        clockConfig = DigitalClockConfig.fromFile(clockConfigFile);

        // clockConfig=DigitalClockConfig.fromJson(flipClock.toString());

        clockConfig.skinBasePath =
            "${Application.appRootPath}/skins/${Application.defaultSkin}/";
      } else
        clockConfig = textClock;
    } else
      clockConfig = textClock;
    print("finally use ${clockConfig.skinName} config.");
  }

  @override
  void dispose() {
    AutoOrientation.fullAutoMode();
    Wakelock.disable();
    super.dispose();
  }

  void setDefaultSkin(String skinName) {
    Application.cache.setString(DefaultSkin, skinName);
  }

  void onSettingChange(dynamic t) {
    print(t);
    setState(() {
      reloadConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    if (screenSize.height > screenSize.width) {
      screenSize = Size(screenSize.height, screenSize.width);
    }
    print(screenSize);
    return Scaffold(
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        alignment: Alignment.center,
        color: Colors.grey,
        child: DigitalClock(
          height: screenSize.height,
          width: screenSize.width,
          config: clockConfig,
          onSettingChange: onSettingChange,
        ),
      ),
    );
  }
}
