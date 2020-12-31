import 'dart:convert';
import 'dart:io';

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

class SettingComponent extends StatefulWidget {
  @override
  SettingComponentState createState() => SettingComponentState();
}

class SettingComponentState extends State<SettingComponent> {
  var skinList;
  Map<String, String> skinMap;
  String skinPkgUrl;
  TextStyle settingChapterStyle = TextStyle(fontSize: 20, color: Colors.black);

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
    String skinDir = "${Application.appRootPath}/skins/";
    for (var m in skinList["skin"]) {
      if (skinTitle.compareTo(m["title"]) == 0) {
        String skinName = getFileName(m["file"]);
        if (!File("$skinDir$skinName/config.json").existsSync()) {
          skinPkgUrl = "${Setting.apiDomain}skins/${m["file"]}";
          String skinFile = await saveUrlFile(
              "${Setting.apiDomain}skins/${m["file"]}",
              saveFileWithoutExt: "$skinDir$skinName");

          //extract the archive file
          final zipFile = File(skinFile);
          final destinationDir = Directory(skinDir);
          print(zipFile.path);
          print(destinationDir.path);
          try {
            await ZipFile.extractToDirectory(
                zipFile: zipFile, destinationDir: destinationDir);
          } catch (e) {
            print(e);
          }
        }
        Application.defaultSkin = skinName;
        Application.cache.setString(DefaultSkin, skinName);

        showToast("皮肤已更换为$skinTitle");
        Navigator.pop(context, "setting changed !");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: ListView(children: [
        // Card(
        //   child: Container(
        //     margin: EdgeInsets.all(10),
        //     child: SmartFolder(
        //       // onExpansionChanged: (e) {
        //       //   unfocusAll();
        //       // },
        //       initiallyExpanded: true,
        //       tileColor: Colors.grey,
        //       child: Container(
        //         alignment: Alignment.centerLeft,
        //         child: ListTile(
        //           leading: Icon(
        //             Icons.settings,
        //             color: Colors.black,
        //             size: 32,
        //           ),
        //           dense: true,
        //           title: Text(
        //             "样式",
        //             style: settingChapterStyle,
        //           ),
        //         ),
        //       ),
        //       children: [
        //         Divider(
        //           color: Colors.grey,
        //           thickness: 1.0,
        //         ),
        //         ImageCardList(
        //           height: 100,
        //           width: 100,
        //           map: {
        //             "数字时钟": "assets/clock/sample.png",
        //             "表盘时钟": "assets/clock/watch.jpg",
        //           },
        //           displayNameTag: true,
        //         )
        //       ],
        //     ),
        //   ),
        // ),
        skinMap != null
            ? Card(
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
                          color: Colors.black,
                          size: 32,
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
                        map: skinMap,
                        displayNameTag: true,
                        onTap: changeSkin,
                      )
                    ],
                  ),
                ),
              )
            : Container(),
        Card(
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
                    color: Colors.black,
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
                  title: Text("退出程序"),
                  trailing: Icon(
                    Icons.exit_to_app,
                    size: 32,
                  ),
                  onTap: () => SystemNavigator.pop(),
                ),
                ListTile(
                    title: Text("返回"),
                    trailing: Icon(
                      Icons.keyboard_return,
                      size: 32,
                    ),
                    onTap: () => Navigator.pop(context))
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
