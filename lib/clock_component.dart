import 'dart:io';
import 'package:digital_clock/digital_clock.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:colours/colours.dart';
import 'package:cron/cron.dart';
import 'package:flutter/services.dart';
import 'package:justclock/config/application.dart';
import 'package:justclock/config/constants.dart';
import 'package:justclock/config/setting.dart';
import 'package:justclock/pkg/utils.dart';
import 'package:justclock/widget/Toast.dart';
import 'package:justclock/widget/clockSetting.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:justclock/pkg/logger.dart' as log;
import 'package:logging/logging.dart';

class ClockComponent extends StatefulWidget {
  @override
  ClockComponentState createState() => ClockComponentState();
}

class ClockComponentState extends State<ClockComponent>
    with WidgetsBindingObserver {
  final Logger logger = log.newInstanse(logTag: "JustClock");
  bool forceInit = false;
  AlarmClock myClock;
  Cron cron;

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
    timeType: TimeType.h24,
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

  DigitalClockConfig flipClock3 = DigitalClockConfig(
    "SimpleFlipClock",
    height: 360,
    width: 640,
    foregroundColor: Colors.grey,
    backgroundColor: Colors.black,
    blinkColor: Colors.grey,
    backgroundImage: null,
    bodyImage: ItemConfig(
      style: H12Style.pic.index,
      rect: Rect.fromCenter(center: Offset(0, 0), width: 461, height: 261),
      imgs: ["body.png"],
    ),
    timeType: TimeType.h12,
    skinBasePath: "assets:skin/SimpleFlipClock/",
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
    h12Item: ItemConfig(
      style: H12Style.pic.index,
      rect: Rect.fromCenter(center: Offset(-200, -94), width: 45, height: 39),
      imgs: ["am.png", "pm.png"],
    ),
    tiktokItem: null,
    settingItem: ItemConfig(
      style: H12Style.pic.index,
      rect: Rect.fromCenter(center: Offset(-119, 1), width: 222, height: 239),
    ),
    exitItem: ItemConfig(
      style: H12Style.pic.index,
      rect: Rect.fromCenter(center: Offset(119, 1), width: 222, height: 239),
    ),
    slientItem: ItemConfig(
      style: ActionStyle.icon.index,
      rect: Rect.fromCenter(center: Offset(260, -110), width: 32, height: 32),
      imgs: [
        Icons.notifications_off.codePoint.toString(),
        Icons.notifications.codePoint.toString()
      ],
    ),
  );

  DigitalClockConfig clockConfig;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); //添加观察者
    // vibrate.init();
    //
    // sound.init();

    AutoOrientation.landscapeAutoMode();

    checkUpgrade();
    reloadConfig();
    // clockConfig=textClock;
    // clockConfig=flipClock3;
    // clockConfig.skinBasePath =
    // "${Application.appRootPath}/skins/${flipClock3.skinBasePath}/";

    // largePrint(textClock);
    // largePrint(flipClock);
    // largePrint(flipClock3);

    // Schedule keepWakeup = Schedule.parse("* * $hiberBegin-$hiberEnd * * 1-5");
    // if (keepWakeup.match(DateTime.now())) {
    //   // print("Time match,set wakelock to enable");
    //   Wakelock.enable();
    // }

    // cron = Cron();
    // cron.schedule(Schedule.parse("0 0 $hiberBegin * * 1-5"), Wakelock.disable);
    // cron.schedule(Schedule.parse("0 0 $hiberEnd * * 1-5"), Wakelock.enable);
    // cron.schedule(
    //     Schedule(
    //       minutes: [0, 15, 30, 45],
    //       // weekdays: [1, 2, 3, 4, 5],
    //     ),
    //     clockAlert);
    myClock = AlarmClock(
        newSchedule: Schedule(
          minutes: [0, 15, 30, 45],
        ),
        quarterAlarmSound: "assets/voices/钟琴颤音.mp3",
        halfAlarmSound: "assets/voices/短促欢愉.mp3",
        oclockAlarmSound: "assets/voices/座钟报时.mp3",
        noSoundSchedule: Schedule(hours: [23, 0, 1, 2, 3, 4, 5, 6]),
        noWakeLockSchedule: Schedule(hours: "8-15", weekdays: "1-5"),
        sleepEnableAction: () =>
            logger.fine("sleepEnableAction() run ${Wakelock.disable()}"),
        sleepDisableAction: () =>
            logger.fine("sleepDisableAction() run ${Wakelock.enable()}"));
    myClock.addSpecialSchedule(
        Schedule(hours: "2-5"), "已经 {} 了，熬夜看书不是个好习惯，赶紧睡吧");
    myClock.addSpecialSchedule(
        Schedule(hours: [23, 0, 1]), "夜猫子，不要看太晚了，已经 {} 了");
    myClock.addSpecialSchedule(Schedule(hours: "6-8"), "早起读书精神爽，现在是 {} 了");
    myClock.addSpecialSchedule(Schedule(hours: 9), "抓紧时间上班吧，已经 {} 了");
    myClock.addSpecialSchedule(
        Schedule(hours: [10, 11, 14, 15, 16, 17]), "上班摸鱼可不是好习惯，现在是 {}");
    myClock.addSpecialSchedule(Schedule(hours: 12), "现在是 {}，赶紧吃饭去吧");
    myClock.addSpecialSchedule(Schedule(hours: 13), "现在是 {}，午休时间哦，眯一会儿吧");
    myClock.addSpecialSchedule(Schedule(hours: 18), "现在是 {}，总算下班了");
    myClock.addSpecialSchedule(Schedule(hours: "19-22"), "只要不加班，快活到天亮，现在是 {}");
    myClock.addSpecialSchedule(
        Schedule(days: 15, months: 4), "今天是闹钟模块诞生的日子，值得纪念");
  }


  @override
  void didChangeMetrics() {
    Application.screenSize = WidgetsBinding.instance.window.physicalSize;
    // print(screenSize);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logger.fine("didChangeAppLifecycleState=[$state]");
    super.didChangeAppLifecycleState(state);
  }

  void checkUpgrade() {
    Future.delayed(Duration(milliseconds: 2000), () async {
      //强制升级
      if (Application.appCanUpgrade &&
          Setting.androidAppUrl != null &&
          Setting.isForceUpdate &&
          Platform.isAndroid) {
        // showToast(LocaleKeys.launch_forceUpgradeAlert.tr(),showInSec: 15);
        showToast(Setting.androidUpdateLog, showInSec: 15);
        String apkFile = await saveUrlFile(Setting.androidAppUrl);
        Vibrate.littleShake();
        await installApk(apkFile, AppId);
      }
    });
  }

  void reloadConfig() {
    if (Application.defaultSkin != null && !forceInit) {
      // Application.defaultSkin="DigitalFlipClock";

      logger.fine("load ${Application.defaultSkin} skin");
      try {
        File clockConfigFile = File(
            "${Application.appRootPath}/skins/${Application.defaultSkin}/config.json");

        if (clockConfigFile.existsSync()) {
          clockConfig = DigitalClockConfig.fromFile(clockConfigFile);

          // clockConfig=DigitalClockConfig.fromJson(flipClock.toString());

          clockConfig.skinBasePath =
              "${Application.appRootPath}/skins/${Application.defaultSkin}/";
        } else
          clockConfig = textClock;
      } catch (e) {
        logger.warning(e);
        Application.cache.remove(DefaultSkin);
        clockConfig = textClock;
      }
    } else {
      clockConfig = textClock;
      forceInit = false;
    }
    logger.fine("finally use ${clockConfig.skinName} config.");
    largePrint(clockConfig.toString());
  }

  @override
  void dispose() {
    AutoOrientation.fullAutoMode();
    Wakelock.disable();
    myClock.dispose();
    super.dispose();
  }

  void setDefaultSkin(String skinName) {
    Application.cache.setString(DefaultSkin, skinName);
  }

  void defaultExitAction(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("您真的要退出时钟程序吗？"),
              actions: <Widget>[
                TextButton(
                  child: Text("按错了"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  child: Text("狠心离开"),
                  onPressed: () => SystemNavigator.pop(),
                ),
              ],
            ));
  }

  void onClockEvent(dynamic t) {
    if (t is ClockEvent) {
      logger.fine("ClockEvent:${t.clockEventType.toString()} fired");
      switch (t.clockEventType) {
        case ClockEventType.skinChange:
          setState(() {
            reloadConfig();
          });
          break;
        case ClockEventType.setting:
          showSettingCompoment(context);
          break;
        case ClockEventType.sleepScheduleChange:
          myClock.noWakeLockSchedule = t.value;
          break;
        case ClockEventType.slientScheduleChange:
          myClock.noSoundSchedule = t.value;
          break;
        case ClockEventType.slientChange:
          myClock.setSlient = t.value;
          break;
        case ClockEventType.exit:
        default:
          break;
      }
    }
  }

  void showSettingCompoment(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return SettingComponent();
      },
    )).then((value) => onClockEvent(value));
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    if (screenSize.height > screenSize.width) {
      screenSize = Size(screenSize.height, screenSize.width);
    }
    logger.fine("Screen ${screenSize.toString()}");
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
          onClockEvent: onClockEvent,
          // onExitAction: defaultExitAction,
        ),
      ),
    );
  }
}
