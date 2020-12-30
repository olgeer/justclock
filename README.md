# justclock

一个时钟控件，可以根据config文件的不同进行配置外观及行为.

## 计划

现在还没进行控件化，还是以独立程序的形式执行，近期会将其控件化并放到pub.dev上。

### 如何使用
组件名称为 DigitalClock

初始化：
```dart
    DigitalClock(
      height: screenSize.height,
      width: screenSize.width,
      config: clockConfig,
      onSettingChange: onSettingChange,
    )
```

其中config为DigitalClockConfig类，使用可参照：
```dart
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
    backgroundImage: "bg.png",
    bodyImage: "body.png",
    timeType: TimeType.h12,
  );
```

其中ItemConfig的属性定义如下：
```dart
  int style;         //样式的index值，根据item的不同有不同的对应关系
  Rect rect;         //item的作用范围，采用中心坐标
  List<String> imgs; //优先使用imgs，如果imgs为null，则检测imgPrename和imgExtname;
  String imgPrename; //系列图片的前缀，如 hour00.png 中的 "hour"
  String imgExtname; //系列图片的后缀，如 hour00.png 中的 ".png"
  TextStyle textStyle;  //文本显示样式，当item样式为文本时有效，其余忽略
```

涉及到的样式有以下几种：
```dart
enum ClockStyle { digital, watch }
enum DateStyle { number, chinese, english, shortEnglish, pic }
enum TimeStyle { number, chinese, pic, flip }
enum TimeType { h24, h12 }
enum H12 { am, pm }
enum H12Style { text, pic, icon }
enum TikTokStyle { text, pic, icon }
enum ActionStyle { text, pic, icon, empty }
```

##完整的示例
```dart
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
      textStyle: TextStyle(fontSize: 50, color: Colors.white),
      rect: Rect.fromCenter(center: Offset(-33, 0), width: 60, height: 46),
    ),
    minuteItem: ItemConfig(
      style: TimeStyle.number.index,
      textStyle: TextStyle(fontSize: 50, color: Colors.white),
      rect: Rect.fromCenter(center: Offset(47, 0), width: 60, height: 46),
    ),
    tiktokItem: ItemConfig(
        style: TikTokStyle.text.index,
        textStyle: TextStyle(fontSize: 50, color: Colors.white),
        rect: Rect.fromCenter(center: Offset(7, 0), width: 14, height: 46)),
    h12Item: ItemConfig(
      style: H12Style.text.index,
      textStyle: TextStyle(fontSize: 9, color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    if (screenSize.height > screenSize.width) {
      screenSize = Size(screenSize.height, screenSize.width);
    }
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
```