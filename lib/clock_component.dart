import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:colours/colours.dart';
import 'package:justclock/config/application.dart';
import 'package:justclock/config/constants.dart';
import 'package:justclock/widget/digitalClock.dart';
import 'package:flutter/material.dart';

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
      rect: Rect.fromCenter(center: Offset(-33, 0), width: 60, height: 46),
    ),
    minuteItem: ItemConfig(
      style: TimeStyle.number.index,
      textStyle: TextStyle(fontSize: 50, color: Colours.lightGoldenRodYellow),
      rect: Rect.fromCenter(center: Offset(47, 0), width: 60, height: 46),
    ),
    tiktokItem: ItemConfig(
        style: TikTokStyle.text.index,
        textStyle: TextStyle(fontSize: 50, color: Colours.lightGoldenRodYellow),
        rect: Rect.fromCenter(center: Offset(7, 0), width: 14, height: 46)),
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
    backgroundColor: Colors.black,
    backgroundImage: "bg.png",
    bodyImage: "body2.png",
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
    exitItem: ItemConfig(
      style: H12Style.pic.index,
      rect: Rect.fromCenter(center: Offset(238, 100), width: 45, height: 50),
    ),
  );

  DigitalClockConfig flipClock = DigitalClockConfig(
    "DigitalFlipClock",
    height: 360,
    width: 640,
    backgroundColor: Colors.black,
    backgroundImage: "bg.png",
    bodyImage: "body2.png",
    timeType: TimeType.h12,
    skinBasePath: "DigitalFlipClock",
    hourItem: ItemConfig(
      style: TimeStyle.flip.index,
      rect: Rect.fromCenter(center: Offset(-146, 10), width: 210, height: 233),
      textStyle: TextStyle(fontSize: 180, color: Colors.white),
    ),
    minuteItem: ItemConfig(
      style: TimeStyle.flip.index,
      rect: Rect.fromCenter(center: Offset(93, 10), width: 210, height: 233),
      textStyle: TextStyle(fontSize: 180, color: Colors.white),
    ),
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
    exitItem: ItemConfig(
      style: H12Style.pic.index,
      rect: Rect.fromCenter(center: Offset(238, 100), width: 45, height: 50),
    ),
  );

  DigitalClockConfig clockConfig;

  @override
  void initState() {
    AutoOrientation.landscapeAutoMode();
    reloadConfig();
    // largePrint(textClock);
    // largePrint(flipClock);
    // largePrint(flipClock2);
  }

  void reloadConfig() {
    if (Application.defaultSkin != null) {
      print("load ${Application.defaultSkin} skin");
      File clockConfigFile=File(
          "${Application.appRootPath}/skins/${Application.defaultSkin}/config.json");
      if(clockConfigFile.existsSync()) {
        clockConfig = DigitalClockConfig.fromFile(clockConfigFile);
        clockConfig.skinBasePath =
        "${Application.appRootPath}/skins/${Application.defaultSkin}/";
      }else
        clockConfig = textClock;
    } else
      clockConfig = textClock;
  }

  @override
  void dispose() {
    AutoOrientation.fullAutoMode();
    super.dispose();
  }

  void setDefaultSkin(String skinName) {
    Application.cache.setString(DefaultSkin, skinName);
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
        ),
      ),
    );
  }
}
