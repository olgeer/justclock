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
  Map<String, String> skinMap;
  String skinPkgUrl;
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
    ))
        .bodyBytes);
    // showToast(skinJson);

    skinList = json.decode(skinJson);
    if (skinList != null && skinList["skin"] != null) {
      skinMap = Map<String, String>();
      for (var m in skinList["skin"]) {
        skinMap.putIfAbsent(
            m["title"], () => "${Setting.apiDomain}skins/${m["sample"]}");
      }
    }
    setState(() {});
  }

  void changeSkin(String skinTitle, ImageProvider sample) async {
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
          String skinFile = await saveUrlFile(
              "${Setting.apiDomain}skins/${m["file"]}",
              saveFileWithoutExt: "$skinDir$skinName");

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
        Application.defaultSkin = skinName;
        Application.cache.setString(DefaultSkin, skinName);

        showToast("皮肤已更换为$skinTitle");
        Navigator.pop(
            context, ClockEvent(ClockEventType.skinChange, value: skinName));
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
      end: TimeOfDay(hour: 17, minute: 0),
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

    showToast("休眠时段已设定为周一至周五， ${fromTimeRange(result)} 点");

    Navigator.pop(
        context,
        ClockEvent(ClockEventType.sleepScheduleChange,
            value: Schedule(hours: fromTimeRange(result), weekdays: "1-5")));
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

    showToast("静音时段间已设定为 ${fromTimeRange(result)} 点");

    Navigator.pop(
        context,
        ClockEvent(ClockEventType.slientScheduleChange,
            value: Schedule(hours: fromTimeRange(result))));
  }

  void upgradeApk() async {
    //防止二次提交
    setState(() {
      isProcessing = true;
    });

    showToast("正在升级应用，请稍后。。。");
    String apkFile = await saveUrlFile(Setting.androidAppUrl);
    Vibration.vibrate();
    await installApk(apkFile, AppId);
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
                        map: skinMap,
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
                  onTap: isProcessing ? null : upgradeApk,
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
