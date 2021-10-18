import 'dart:convert';
import 'dart:io';

import 'package:cron/cron.dart';
import 'package:digital_clock/digital_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:justclock/config/application.dart';
import 'package:justclock/config/constants.dart';
import 'package:justclock/config/setting.dart';
import 'package:justclock/pkg/utils.dart';
import 'package:justclock/widget/SmartFolder.dart';
import 'package:justclock/widget/Toast.dart';
import 'package:justclock/widget/imageCardList.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:vibration/vibration.dart';
import 'package:justclock/pkg/logger.dart' as log;
import 'package:logging/logging.dart';

class SettingComponent extends StatefulWidget {
  @override
  SettingComponentState createState() => SettingComponentState();
}

class SettingComponentState extends State<SettingComponent> {
  final Logger logger = log.newInstanse(logTag: "SettingComponent");
  var skinList;
  Map<String, String>? skinMap;
  late String skinPkgUrl;
  final Color themeColor = Colors.teal.shade300;
  final TextStyle settingChapterStyle =
      TextStyle(fontSize: 20, color: Colors.teal.shade300);
  bool forceUpdate = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    loadSkinList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadSkinList() async {
    String skinJson = utf8.decode((await getUrlFile(
      "${Setting.apiDomain}www/skinlist.json",
    ))?.bodyBytes??[]);
    // showToast(skinJson);

    skinList = json.decode(skinJson);
    if (skinList != null && skinList["skin"] != null) {
      skinMap = Map<String, String>();
      for (var m in skinList["skin"]) {
        skinMap!.putIfAbsent(
            m["title"], () => "${Setting.apiDomain}skins/${m["sample"]}");
      }
    }
    setState(() {});
  }

  void changeSkin(String skinTitle, ImageProvider<dynamic> sample) async {
    //防止二次提交
    setState(() {
      isProcessing = true;
    });

    String skinDir = "${Application.appRootPath}/skins/";
    for (var m in skinList["skin"]) {
      if (skinTitle.compareTo(m["title"]) == 0) {
        String skinName = getFileName(m["file"]);

        if (!File("$skinDir$skinName/config.json").existsSync() ||
            forceUpdate) {
          skinPkgUrl = "${Setting.apiDomain}skins/${m["file"]}";
          String? skinFile = await saveUrlFile(
              "${Setting.apiDomain}skins/${m["file"]}",
              saveFileWithoutExt: "$skinDir$skinName");

          if(skinFile!=null) {
            //extract the archive file
            final zipFile = File(skinFile);
            final destinationDir = Directory(skinDir);

            try {
              await ZipFile.extractToDirectory(
                  zipFile: zipFile, destinationDir: destinationDir);
              zipFile.deleteSync();
            } catch (e) {
              print(e);
            }
          }
        }

        if(File("$skinDir$skinName/config.json").existsSync()){
          Application.defaultSkin = skinName;
          Application.cache.setString(DefaultSkin, skinName);

          showToast("皮肤已更换为$skinTitle");
          Navigator.pop(
              context, ClockEvent(ClockEventType.skinChange, value: skinName));
        }else{
          showToast("皮肤[$skinName]文件下载或格式错误，无法更换。");
        }
      }
    }
  }

  void changeSleepSchedule() async {
    //防止二次提交
    setState(() {
      isProcessing = true;
    });

    TimeRange result = await showTimeRangePicker(
      context: context,
      paintingStyle: PaintingStyle.fill,
      backgroundColor: Colors.grey.withOpacity(0.2),
      labels: [
        ClockLabel.fromTime(time: TimeOfDay(hour: 8, minute: 0), text: "上班"),
        ClockLabel.fromTime(time: TimeOfDay(hour: 18, minute: 0), text: "回家")
      ],
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 8, minute: 0),
      interval: Duration(hours: 1),
      ticks: 8,
      strokeColor: Theme.of(context).primaryColor.withOpacity(0.5),
      ticksColor: Theme.of(context).primaryColor,
      labelOffset: 15,
      padding: 60,
      // disabledTime: TimeRange(
      //     startTime: TimeOfDay(hour: 18, minute: 0),
      //     endTime: TimeOfDay(hour: 8, minute: 0)),
      disabledColor: Colors.red.withOpacity(0.5),
    );

    isProcessing = true;
    setState(() {});

    if(result!=null){
      List<int> tempRange =fromTimeRange(result);
      if(tempRange.length>1) {
        showToast("休眠时段已设定为周一至周五， $tempRange 点");

        Navigator.pop(
            context,
            ClockEvent(ClockEventType.sleepScheduleChange,
                value: Schedule(
                    hours: fromTimeRange(result), weekdays: "1-5")));
      }else{
        showToast("休眠时段已取消");

        Navigator.pop(
            context,
            ClockEvent(ClockEventType.sleepScheduleChange));
      }
    }
  }

  void changeSlientSchedule() async {
    //防止二次提交
    setState(() {
      isProcessing = true;
    });

    TimeRange result = await showTimeRangePicker(
      context: context,
      paintingStyle: PaintingStyle.fill,
      backgroundColor: Colors.grey.withOpacity(0.2),
      labels: [
        ClockLabel.fromTime(time: TimeOfDay(hour: 7, minute: 0), text: "起床"),
        ClockLabel.fromTime(time: TimeOfDay(hour: 23, minute: 0), text: "睡觉")
      ],
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 6, minute: 0),
      interval: Duration(hours: 1),
      ticks: 8,
      strokeColor: Theme.of(context).primaryColor.withOpacity(0.5),
      ticksColor: Theme.of(context).primaryColor,
      labelOffset: 15,
      padding: 60,
      // disabledTime: TimeRange(
      //     startTime: TimeOfDay(hour: 7, minute: 0),
      //     endTime: TimeOfDay(hour: 23, minute: 0)),
      disabledColor: Colors.redAccent.withOpacity(0.5),
    );

    isProcessing = true;
    setState(() {});

    if(result!=null) {
      List<int> tempRange = fromTimeRange(result);
      if (tempRange.length > 1) {
        showToast("静音时段间已设定为 ${fromTimeRange(result)} 点");

        Navigator.pop(
            context,
            ClockEvent(ClockEventType.slientScheduleChange,
                value: Schedule(hours: fromTimeRange(result))));
      }else{
        showToast("已取消静音时段间");

        Navigator.pop(
            context,
            ClockEvent(ClockEventType.slientScheduleChange));
      }
    }
  }

  void runUpgradeApk() async {
    //防止二次提交
    setState(() {
      isProcessing = true;
    });

    if(Setting.androidAppUrl!=null){
      showToast("正在升级应用，请稍候。。。");
      Vibration.vibrate();
      // String? apkFile = await saveUrlFile(Setting.androidAppUrl!);
      // if(apkFile!=null) {
      //   await installApk(apkFile, AppId);
      // }else{
      //   showToast("升级文件下载错误，请稍后再试！");
      // }
      await upgradeApk(Setting.androidAppUrl!,fileName: "app.apk");
    }else{
      showToast("未找到应用升级路径，请稍后再试！");
    }
  }

  List<int> fromTimeRange(TimeRange t) {
    List<int> hours = [];
    int i = t.startTime.hour;
    while (i != t.endTime.hour) {
      hours.add(i);
      i++;
      if (i == 24) i = 0;
    }
    hours.add(i);
    return hours;
  }

  void setAlarmCache({bool? isQuarterAlarm,bool? isHalfAlarm,bool? isHourAlarm,bool? enableVibrate,bool? enableFlash,bool? enableSound}){
    if(isQuarterAlarm!=null){
      Application.myClock!.canQuarterAlarm=isQuarterAlarm;
      Application.cache.setBool(QuarterAlarmTag, isQuarterAlarm);
    }
    if(isHalfAlarm!=null){
      Application.myClock!.canHalfAlarm=isHalfAlarm;
      Application.cache.setBool(HalfAlarmTag, isHalfAlarm);
    }
    if(isHourAlarm!=null){
      Application.myClock!.canHourAlarm=isHourAlarm;
      Application.cache.setBool(HourAlarmTag, isHourAlarm);
    }
    if(enableSound!=null){
      Application.myClock!.enableAlarmSound=enableSound;
      Application.cache.setBool(EnableSoundTag, enableSound);
    }
    if(enableFlash!=null){
      Application.myClock!.enableFlashLamp=enableFlash;
      Application.cache.setBool(EnableFlashTag, enableFlash);
    }
    if(enableVibrate!=null){
      Application.myClock!.enableVibrate=enableVibrate;
      Application.cache.setBool(EnableVibrateTag, enableVibrate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: ListView(children: [
        skinMap != null
            ? Card(
                color: Colors.grey.shade200,
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: SmartFolder(
                    initiallyExpanded: true,
                    tileColor: Colors.grey,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: ListTile(
                        leading: Icon(
                          Icons.palette,
                          color: themeColor,
                          size: 32,
                        ),
                        trailing: Container(
                          width: 120,
                          child: Row(
                            children: [
                              Text("强制下载"),
                              Expanded(
                                  child: Switch(
                                value: forceUpdate,
                                onChanged: (v) {
                                  setState(() {
                                    forceUpdate = v;
                                  });
                                },
                              ))
                            ],
                          ),
                        ),
                        dense: true,
                        title: Text(
                          "皮肤",
                          style: settingChapterStyle,
                        ),
                      ),
                    ),
                    children: [
                      Divider(
                        color: Colors.grey,
                        thickness: 1.0,
                      ),
                      ImageCardList(
                        height: 100,
                        width: 100,
                        titleColor: themeColor,
                        map: skinMap??{},
                        displayNameTag: true,
                        onTap: isProcessing ? null : changeSkin,
                      )
                    ],
                  ),
                ),
              )
            : Container(),
        Card(
          color: Colors.grey.shade200,
          child: Container(
            margin: EdgeInsets.all(10),
            child: SmartFolder(
              initiallyExpanded: true,
              tileColor: Colors.grey,
              child: Container(
                alignment: Alignment.centerLeft,
                child: ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: themeColor,
                    size: 32,
                  ),
                  dense: true,
                  title: Text(
                    "操作",
                    style: settingChapterStyle,
                  ),
                ),
              ),
              children: [
                Divider(
                  color: Colors.grey,
                  thickness: 1.0,
                ),
                ListTile(
                    title: Text("报时设置"),
                    trailing: Container(
                      width: 230,
                        child: Row(children: [
                      Checkbox(value: Application.myClock!.canQuarterAlarm, onChanged: (v)=>setState(()=>setAlarmCache(isQuarterAlarm: v))),
                          Text("刻钟"),
                      Checkbox(value: Application.myClock!.canHalfAlarm, onChanged: (v)=>setState(()=>setAlarmCache(isHalfAlarm: v))),
                          Text("半点"),
                      Checkbox(value: Application.myClock!.canHourAlarm, onChanged: (v)=>setState(()=>setAlarmCache(isHourAlarm: v))),
                          Text("整点"),
                    ],))),
                ListTile(
                    title: Text("提醒方式"),
                    trailing: Container(
                        width: 230,
                        child: Row(children: [
                          Checkbox(value: Application.myClock!.enableVibrate, onChanged: (v)=>setState(()=>setAlarmCache(enableVibrate: v))),
                          Text("震动"),
                          Checkbox(value: Application.myClock!.enableFlashLamp, onChanged: (v)=>setState(()=>setAlarmCache(enableFlash: v))),
                          Text("闪光灯"),
                          Checkbox(value: Application.myClock!.enableAlarmSound, onChanged: (v)=>setState(()=>setAlarmCache(enableSound: v))),
                          Text("振铃"),
                        ],))),
                Divider(
                  color: Colors.grey,
                  thickness: 1.0,
                ),
                ListTile(
                    title: Text("休眠时段"),
                    trailing: Icon(
                      LineAwesomeIcons.moon,
                      color: Colors.indigo,
                      size: 32,
                    ),
                    onTap: isProcessing ? null : changeSleepSchedule),
                ListTile(
                    title: Text("免打搅时段"),
                    trailing: Icon(
                      LineAwesomeIcons.bell_slash,
                      color: Colors.teal,
                      size: 32,
                    ),
                    onTap: isProcessing ? null : changeSlientSchedule),
                Divider(
                  color: Colors.grey,
                  thickness: 1.0,
                ),
                ListTile(
                    title: Text("返回"),
                    trailing: Icon(
                      Icons.keyboard_return,
                      color: Colors.lightBlue,
                      size: 32,
                    ),
                    onTap: () => Navigator.pop(context)),
                ListTile(
                  title: Text("退出程序"),
                  trailing: Icon(
                    Icons.exit_to_app,
                    color: Colors.orangeAccent.shade200,
                    size: 32,
                  ),
                  onTap: () => SystemNavigator.pop(),
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 1.0,
                ),
                ListTile(
                  title: Text("纯粹时钟"),
                  subtitle: Text("版本：$AppVersion      开发者： olgeer@163.com"),
                  trailing: Icon(
                    LineAwesomeIcons.helicopter,
                    size: 32,
                    color: Colors.greenAccent,
                  ),
                  onTap: isProcessing ? null : runUpgradeApk,
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
