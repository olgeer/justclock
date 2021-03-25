import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:justclock/widget/FlipNumber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:justclock/widget/clockSetting.dart';
import 'package:justclock/pkg/utils.dart';
import 'package:wakelock/wakelock.dart';

class DigitalClock extends StatefulWidget {
  final double height;
  final double width;
  DigitalClockConfig config;
  eventCall onSettingChange;

  DigitalClock({
    this.height = 100,
    this.width = 200,
    @required this.config,
    this.onSettingChange,
  })  : assert(config != null),
        super();

  @override
  State<StatefulWidget> createState() => DigitalClockState();
}

class DigitalClockState extends State<DigitalClock> {
  int hours, minutes, years, months, days, weekday;
  int h12 = 0, tk = 0;
  String currentSkinName;
  String skinBasePath;
  Timer clockTimer;
  double scale = 1;
  Widget nullWidget = Container();
  FlipNumber hourFlipNumber, minuteFlipNumber;
  Duration animationDuration;
  double xScale, yScale;

  @override
  void initState() {
    init();
    tiktok();
    clockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      tiktok();
    });
    super.initState();

    // largePrint(widget.config);
  }

  @override
  void dispose() {
    clockTimer.cancel();
    Wakelock.disable();
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  void init() {
    currentSkinName = widget.config.skinName;
    xScale = widget.width / widget.config.width;
    yScale = widget.height / widget.config.height;
    scale = xScale < yScale ? xScale : yScale;
    print("widget.width=${widget.width} widget.height=${widget.height}");
    print("xs=$xScale ys=$yScale scale=$scale");

    skinBasePath = widget.config.skinBasePath;

    animationDuration = Duration(milliseconds: 2300);

    refreshTime(DateTime.now());

    if (widget.config.hourItem?.style == TimeStyle.flip.index) {
      hourFlipNumber = FlipNumber(
        scale: scale,
        basePath: skinBasePath,
        numberItem: widget.config.hourItem,
        animationDuration: animationDuration,
        canRevese: false,
        isPositiveSequence: true,
        min: widget.config.timeType == TimeType.h12 ? 1 : 0,
        max: widget.config.timeType == TimeType.h12 ? 12 : 23,
        currentValue: hours,
      );
    } else {
      if (hourFlipNumber != null) {
        // hourFlipNumber.controller.dispose();
        hourFlipNumber = null;
      }
    }

    if (widget.config.minuteItem?.style == TimeStyle.flip.index) {
      minuteFlipNumber = FlipNumber(
        scale: scale,
        basePath: skinBasePath,
        numberItem: widget.config.minuteItem,
        animationDuration: animationDuration,
        canRevese: false,
        isPositiveSequence: true,
        min: 0,
        max: 59,
        currentValue: minutes,
      );
    } else {
      if (minuteFlipNumber != null) {
        // minuteFlipNumber.controller.dispose();
        minuteFlipNumber = null;
      }
    }

    Wakelock.enable();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  void refreshTime(DateTime now) {
    years = now.year;
    months = now.month;
    days = now.day;
    weekday = now.weekday;
    hours = getHour(now.hour);
    minutes = now.minute;
  }

  int getHour(int h) {
    int hour = h;
    if (widget.config.timeType == TimeType.h12) {
      if (h > 12) {
        hour -= 12;
        h12 = 1;
      } else
        h12 = 0;
    }
    return hour;
  }

  void tiktok() {
    DateTime now = DateTime.now();

    if (getHour(now.hour) != hours && hourFlipNumber != null) {
      hourFlipNumber?.controller?.forward();
    }
    if (now.minute != minutes && minuteFlipNumber != null) {
      minuteFlipNumber?.controller?.forward();
    }

    setState(() {
      refreshTime(now);
      tk = (tk - 1).abs();
    });
  }

  EdgeInsets buildEdgeRect(Rect itemRect) {
    double rectScale = scale;
    double l = ((widget.config.width / 2) + itemRect.left) * rectScale;
    double t = ((widget.config.height / 2) + itemRect.top) * rectScale;
    double r = ((widget.config.width / 2) - itemRect.right) * rectScale;
    double b = ((widget.config.height / 2) - itemRect.bottom) * rectScale;
    // print("EdgeInsets.fromLTRB($l,$t,$r,$b)");
    return EdgeInsets.fromLTRB(l, t, r, b);
  }

  Widget buildTextItem(
      String itemText, Rect itemRect, TextStyle itemTextStyle) {
    TextStyle scaleTextStyle =
        itemTextStyle.copyWith(fontSize: itemTextStyle.fontSize * scale);
    return Container(
      // color: Colors.white12,
      height: widget.config.height * scale,
      width: widget.config.width * scale,
      margin: buildEdgeRect(itemRect),
      alignment: Alignment.center,
      child: Text(
        itemText,
        style: scaleTextStyle,
      ),
    );
  }

  Widget buildPicItem(int value, ItemConfig picItem) {
    String picName;
    if (picItem.imgs != null &&
        picItem.imgs.isNotEmpty &&
        value < picItem.imgs.length) {
      picName = widget.config.skinBasePath + picItem.imgs[value];
    } else {
      picName =
          "${widget.config.skinBasePath}${picItem.imgPrename ?? ""}${int2Str(value)}${picItem.imgExtname ?? ""}";
    }
    // print(picName);
    return Container(
      // color: Colors.white12,
      height: widget.config.height * scale,
      width: widget.config.width * scale,
      margin: buildEdgeRect(picItem.rect),
      alignment: Alignment.center,
      child: Image.file(
        File(picName),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildHourFlipItem(int value, ItemConfig picItem, String basePath) {
    return Container(
      height: widget.config.height * scale,
      width: widget.config.width * scale,
      margin: buildEdgeRect(picItem.rect),
      alignment: Alignment.center,
      child: hourFlipNumber,
    );
  }

  Widget buildMinuteFlipItem(int value, ItemConfig picItem, String basePath) {
    return Container(
      height: widget.config.height * scale,
      width: widget.config.width * scale,
      margin: buildEdgeRect(picItem.rect),
      alignment: Alignment.center,
      child: minuteFlipNumber,
    );
  }

  Widget buildYear(int y, ItemConfig ic) {
    if (ic == null) return nullWidget;
    Widget retWidget;

    switch (DateStyle.values[ic.style]) {
      case DateStyle.number:
        retWidget = buildTextItem(int2Str(y, width: 4), ic.rect, ic.textStyle);
        break;
      case DateStyle.chinese:
        retWidget =
            buildTextItem(int2Str(y, width: 4) + "年", ic.rect, ic.textStyle);
        break;
      case DateStyle.english:
        retWidget = buildTextItem(int2Str(y, width: 4), ic.rect, ic.textStyle);
        break;
      case DateStyle.shortEnglish:
        retWidget = buildTextItem(int2Str(y, width: 4), ic.rect, ic.textStyle);
        break;
      case DateStyle.pic:
        break;
    }
    return retWidget;
  }

  Widget buildMonth(int m, ItemConfig ic) {
    if (ic == null) return nullWidget;
    final chsMonths = [
      "一月",
      "二月",
      "三月",
      "四月",
      "五月",
      "六月",
      "七月",
      "八月",
      "九月",
      "十月",
      "十一月",
      "十二月"
    ];
    final engMonths = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    final shortEngMonths = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    Widget retWidget;
    switch (DateStyle.values[ic.style]) {
      case DateStyle.number:
        retWidget = buildTextItem(int2Str(m), ic.rect, ic.textStyle);
        break;
      case DateStyle.chinese:
        retWidget = buildTextItem(chsMonths[m - 1], ic.rect, ic.textStyle);
        break;
      case DateStyle.english:
        retWidget = buildTextItem(engMonths[m - 1], ic.rect, ic.textStyle);
        break;
      case DateStyle.shortEnglish:
        retWidget = buildTextItem(shortEngMonths[m - 1], ic.rect, ic.textStyle);
        break;
      case DateStyle.pic:
        break;
    }
    return retWidget;
  }

  Widget buildDay(int d, ItemConfig ic) {
    if (ic == null) return nullWidget;
    final chsDays = [
      "一日",
      "二日",
      "三日",
      "四日",
      "五日",
      "六日",
      "七日",
      "八日",
      "九日",
      "十日",
      "十一日",
      "十二日",
      "十三日",
      "十四日",
      "十五日",
      "十六日",
      "十七日",
      "十八日",
      "十九日",
      "二十日",
      "二十一日",
      "二十二日",
      "二十三日",
      "二十四日",
      "二十五日",
      "二十六日",
      "二十七日",
      "二十八日",
      "二十九日",
      "三十日",
      "三十一"
    ];
    Widget retWidget;
    switch (DateStyle.values[ic.style]) {
      case DateStyle.number:
        retWidget = buildTextItem(int2Str(d), ic.rect, ic.textStyle);
        break;
      case DateStyle.chinese:
        retWidget = buildTextItem(chsDays[d - 1], ic.rect, ic.textStyle);
        break;
      case DateStyle.english:
        retWidget = buildTextItem(int2Str(d), ic.rect, ic.textStyle);
        break;
      case DateStyle.shortEnglish:
        retWidget = buildTextItem(int2Str(d), ic.rect, ic.textStyle);
        break;
      case DateStyle.pic:
        break;
    }
    return retWidget;
  }

  Widget buildWeekDay(int wd, ItemConfig ic) {
    if (ic == null) return nullWidget;
    final chsWeekDays = [
      "星期日",
      "星期一",
      "星期二",
      "星期三",
      "星期四",
      "星期五",
      "星期六",
    ];
    final engWeekDays = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ];
    final shortEngWeekDays = ["Sun", "Mon", "Tue", "Wed", "Thur", "Fri", "Sat"];

    Widget retWidget;
    switch (DateStyle.values[ic.style]) {
      case DateStyle.number:
        retWidget = buildTextItem(shortEngWeekDays[wd], ic.rect, ic.textStyle);
        break;
      case DateStyle.chinese:
        retWidget = buildTextItem(chsWeekDays[wd], ic.rect, ic.textStyle);
        break;
      case DateStyle.english:
        retWidget = buildTextItem(engWeekDays[wd], ic.rect, ic.textStyle);
        break;
      case DateStyle.shortEnglish:
        retWidget = buildTextItem(shortEngWeekDays[wd], ic.rect, ic.textStyle);
        break;
      case DateStyle.pic:
        break;
    }
    return retWidget;
  }

  Widget buildHour(int h, ItemConfig ic) {
    if (ic == null) return nullWidget;
    Widget retWidget;
    switch (TimeStyle.values[ic.style]) {
      case TimeStyle.number:
        retWidget = buildTextItem(int2Str(h, width: 2), ic.rect, ic.textStyle);
        break;
      case TimeStyle.chinese:
        retWidget =
            buildTextItem(int2Str(h, width: 2) + "时", ic.rect, ic.textStyle);
        break;
      case TimeStyle.pic:
        retWidget = buildPicItem(h, ic);
        break;
      case TimeStyle.flip:
        retWidget = buildHourFlipItem(h, ic, skinBasePath);
        break;
    }
    return retWidget;
  }

  Widget buildMinute(int m, ItemConfig ic) {
    if (ic == null) return nullWidget;
    Widget retWidget;
    switch (TimeStyle.values[ic.style]) {
      case TimeStyle.number:
        retWidget = buildTextItem(int2Str(m, width: 2), ic.rect, ic.textStyle);
        break;
      case TimeStyle.chinese:
        retWidget =
            buildTextItem(int2Str(m, width: 2) + "分", ic.rect, ic.textStyle);
        break;
      case TimeStyle.pic:
        retWidget = buildPicItem(m, ic);
        break;
      case TimeStyle.flip:
        retWidget = buildMinuteFlipItem(m, ic, skinBasePath);
        break;
    }
    return retWidget;
  }

  Widget buildTiktok(int t, ItemConfig ic) {
    if (ic == null) return nullWidget;
    Widget retWidget;
    switch (TikTokStyle.values[ic.style]) {
      case TikTokStyle.text:
        retWidget = buildTextItem(t == 0 ? "" : ":", ic.rect, ic.textStyle);
        break;
      case TikTokStyle.icon:
        break;
      case TikTokStyle.pic:
        retWidget = buildPicItem(t, ic);
        break;
    }
    return retWidget;
  }

  Widget buildH12(int f, ItemConfig ic) {
    if (ic == null) return nullWidget;
    Widget retWidget;
    switch (H12Style.values[ic.style]) {
      case H12Style.text:
        retWidget = buildTextItem(f == 0 ? "AM" : "PM", ic.rect, ic.textStyle);
        break;
      case H12Style.icon:
        break;
      case H12Style.pic:
        retWidget = buildPicItem(f, ic);
        break;
    }
    return retWidget;
  }

  Widget buildBackgroundImage(String bgImage) {
    if (bgImage == null) return nullWidget;
    return Container(
      height: widget.height,
      width: widget.width,
      child: Image.file(
        File(widget.config.skinBasePath + bgImage),
        fit: BoxFit.fill,
      ),
    );
  }

  Widget buildBodyImage(ItemConfig bodyImage) {
    if (bodyImage == null) return nullWidget;

    String picName;
    if (bodyImage.imgs != null &&
        bodyImage.imgs.isNotEmpty &&
        bodyImage.imgs.length > 0) {
      picName = "${widget.config.skinBasePath}${bodyImage.imgs.first}";
    }
    return Container(
      height: widget.height * scale,
      width: widget.width * scale,
      margin: buildEdgeRect(bodyImage.rect),
      alignment: Alignment.center,
      child: Image.file(
        File(picName),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildExitControl(ItemConfig exitItem) {
    if (exitItem == null) return nullWidget;

    String picName;
    if (exitItem.imgs != null &&
        exitItem.imgs.isNotEmpty &&
        exitItem.imgs.length > 0) {
      picName = "${widget.config.skinBasePath}${exitItem.imgs.first}";
    }
    if (exitItem.imgPrename != null || exitItem.imgExtname != null) {
      picName = "$widget.config.skinBasePath${exitItem.imgPrename}00${exitItem.imgExtname}";
    }
    // print("exitRect:${exitItem.rect}");
    return GestureDetector(
      onTap: () {
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
      },
      child: Container(
        color: Colors.transparent,
        height: widget.config.height * scale,
        width: widget.config.width * scale,
        margin: buildEdgeRect(exitItem.rect),
        alignment: Alignment.center,
        child: exitItem.style == ActionStyle.pic.index && picName != null
            ? Image.asset(
                picName,
                fit: BoxFit.cover,
              )
            : exitItem.style == ActionStyle.icon.index && picName != null
                ? Icon(
                    IconData(int.parse(picName), fontFamily: "MaterialIcons"),
                    color: Colors.white,
                  )
                : nullWidget,
      ),
    );
  }

  Widget buildSettingControl(ItemConfig settingItem, String basePath) {
    if (settingItem == null) return nullWidget;

    String picName;
    if (settingItem.style == ActionStyle.pic.index) {
      if (settingItem.imgs != null &&
          settingItem.imgs.isNotEmpty &&
          settingItem.imgs.length > 0) {
        picName = basePath ?? "" + settingItem.imgs.first;
      }
      if (settingItem.imgPrename != null || settingItem.imgExtname != null) {
        picName =
            "$basePath${settingItem.imgPrename}00${settingItem.imgExtname}";
      }
    }
    if (settingItem.style == ActionStyle.icon.index) {
      if (settingItem.imgs != null &&
          settingItem.imgs.isNotEmpty &&
          settingItem.imgs.length > 0) {
        picName = settingItem.imgs.first;
      }
    }
    // print("skinRect:${skinItem.rect}");
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return SettingComponent();
        },
      )).then((t) {
        if (widget.onSettingChange != null) widget.onSettingChange(t);
      }),
      child: Container(
        color: Colors.transparent,
        height: widget.config.height * scale,
        width: widget.config.width * scale,
        margin: buildEdgeRect(settingItem.rect),
        alignment: Alignment.center,
        child: settingItem.style == ActionStyle.pic.index && picName != null
            ? Image.file(
                File(picName),
                fit: BoxFit.cover,
              )
            : settingItem.style == ActionStyle.icon.index && picName != null
                ? Icon(
                    new IconData(int.parse(picName),
                        fontFamily: "MaterialIcons"),
                    color: widget.config.foregroundColor,
                    size: 12 * scale,
                  )
                : nullWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.skinName.compareTo(currentSkinName) != 0) {
      init();
    }
    return Container(
        height: widget.height,
        width: widget.width,
        color: widget.config.backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ///底色或底图
            buildBackgroundImage(widget.config.backgroundImage),

            ///主体图片
            buildBodyImage(widget.config.bodyImage),

            ///年
            buildYear(years, widget.config.yearItem),

            ///月
            buildMonth(months, widget.config.monthItem),

            ///日
            buildDay(days, widget.config.dayItem),

            ///星期
            buildWeekDay(weekday, widget.config.weekdayItem),

            ///小时
            buildHour(hours, widget.config.hourItem),

            ///分钟
            buildMinute(minutes, widget.config.minuteItem),

            ///Tiktok
            buildTiktok(tk, widget.config.tiktokItem),

            ///上下午标志
            widget.config.timeType == TimeType.h12
                ? buildH12(h12, widget.config.h12Item)
                : Container(),

            ///skin
            buildSettingControl(
                widget.config.settingItem, widget.config.skinBasePath),

            ///exit
            buildExitControl(
                widget.config.exitItem),
          ],
        ));
  }
}

enum ClockStyle { digital, watch }
enum DateStyle { number, chinese, english, shortEnglish, pic }
enum TimeStyle { number, chinese, pic, flip }
enum TimeType { h24, h12 }
enum H12 { am, pm }
enum H12Style { text, pic, icon }
enum TikTokStyle { text, pic, icon }
enum ActionStyle { text, pic, icon, empty }

class ItemConfig {
  int style; //样式的index值，根据item的不同有不同的对应关系
  Rect rect; //item的作用范围，采用中心坐标
  List<String> imgs; //优先使用imgs，如果imgs为null，则检测imgPrename和imgExtname;
  String imgPrename; //系列图片的前缀，如 hour00.png 中的 "hour"
  String imgExtname; //系列图片的后缀，如 hour00.png 中的 ".png"
  TextStyle textStyle; //文本显示样式，当item样式为文本时有效，其余忽略

  ItemConfig({
    this.style,
    this.rect,
    this.imgs,
    this.imgPrename,
    this.imgExtname,
    this.textStyle,
  })  : assert(style != null),
        assert(rect != null);

  static ItemConfig fromString(String itemJsonStr) {
    print(itemJsonStr);
    return json.decode(itemJsonStr);
  }

  static ItemConfig fromJson(Map<String, dynamic> j) {
    if (j == null) return null;
    return ItemConfig(
        style: j["style"],
        rect: json2Rect(j["rect"]),
        imgs: objectListToStringList(j["imgs"]),
        imgPrename: j["imgPrename"],
        imgExtname: j["imgExtname"],
        textStyle: json2TextStyle(j["textStyle"]));
  }

  @override
  String toString() => json.encode(toJson());

  Map<String, dynamic> toJson() {
    return {
      "style": style,
      "rect": rect2Json(rect),
      "imgs": imgs,
      "imgPrename": imgPrename,
      "imgExtname": imgExtname,
      "textStyle": textStyle2Json(textStyle),
    };
  }

  Map<String, dynamic> textStyle2Json(TextStyle ts) {
    if (ts == null) return null;
    return {
      "fontSize": ts?.fontSize,
      "color": ts?.color?.value,
      "fontFamily": ts?.fontFamily,
    };
  }

  static TextStyle json2TextStyle(Map<String, dynamic> jts) {
    if (jts == null) return null;
    return TextStyle(
        fontSize: jts["fontSize"] ?? 12,
        color: Color(jts["color"] ?? 0x00000000),
        fontFamily: jts["fontFamily"]);
  }

  Map<String, double> rect2Json(Rect rect) {
    if (rect == null) return null;
    return {
      "left": rect.left,
      "top": rect.top,
      "right": rect.right,
      "bottom": rect.bottom
    };
  }

  static Rect json2Rect(Map<String, dynamic> jRect) {
    if (jRect == null) return null;
    return Rect.fromLTRB(
        jRect["left"], jRect["top"], jRect["right"], jRect["bottom"]);
  }
}

class DigitalClockConfig {
  static bool debugMode = true;

  String skinName;
  String skinBasePath;

  ///日期相关设置
  ItemConfig yearItem;
  ItemConfig monthItem;
  ItemConfig dayItem;
  ItemConfig weekdayItem;

  ///时间相关设置
  ItemConfig hourItem;
  ItemConfig minuteItem;

  ///12小时模式相关设置
  TimeType timeType;
  ItemConfig h12Item;

  ///秒动态设置
  ItemConfig tiktokItem;

  ///皮肤切换控制
  ItemConfig settingItem;

  ///返回/退出控制
  ItemConfig exitItem;

  ///背景设置
  Color backgroundColor;
  String backgroundImage;

  ///主题颜色
  Color foregroundColor;

  ///主体图片
  ItemConfig bodyImage;

  ///控件基本设置
  double height;
  double width;

  DigitalClockConfig(this.skinName,
      {this.skinBasePath,
      this.yearItem,
      this.monthItem,
      this.dayItem,
      this.weekdayItem,
      this.timeType,
      this.hourItem,
      this.minuteItem,
      this.h12Item,
      this.tiktokItem,
      this.settingItem,
      this.exitItem,
      this.backgroundColor,
      this.backgroundImage,
      this.foregroundColor,
      this.bodyImage,
      this.height,
      this.width});

  static DigitalClockConfig fromFile(File configFile) {
    if (configFile == null || !configFile.existsSync()) return null;
    return fromJson(configFile.readAsStringSync());
  }

  static DigitalClockConfig fromJson(String jsonStr) {
    if (jsonStr == null) return null;
    largePrint(jsonStr);

    var jMap = jsonDecode(jsonStr);
    return DigitalClockConfig(
      jMap["skinName"],
      skinBasePath: jMap["skinBasePath"],
      yearItem: ItemConfig.fromJson(jMap["yearItem"]),
      monthItem: ItemConfig.fromJson(jMap["monthItem"]),
      dayItem: ItemConfig.fromJson(jMap["dayItem"]),
      weekdayItem: ItemConfig.fromJson(jMap["weekdayItem"]),
      hourItem: ItemConfig.fromJson(jMap["hourItem"]),
      minuteItem: ItemConfig.fromJson(jMap["minuteItem"]),
      h12Item: ItemConfig.fromJson(jMap["h12Item"]),
      tiktokItem: ItemConfig.fromJson(jMap["tiktokItem"]),
      settingItem: ItemConfig.fromJson(jMap["settingItem"]),
      exitItem: ItemConfig.fromJson(jMap["exitItem"]),
      backgroundColor: Color(jMap["backgroundColor"] ?? 0x00000000),
      foregroundColor: Color(jMap["foregroundColor"] ?? 0x00ffffff),
      backgroundImage: jMap["backgroundImage"],
      bodyImage: ItemConfig.fromJson(jMap["bodyImage"]),
      timeType: TimeType.values[jMap["timeType"] ?? 1],
      height: jMap["height"],
      width: jMap["width"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "skinName": skinName,
      "skinBasePath": skinBasePath,
      "yearItem": yearItem,
      "monthItem": monthItem,
      "dayItem": dayItem,
      "weekdayItem": weekdayItem,
      "hourItem": hourItem,
      "minuteItem": minuteItem,
      "timeType": timeType?.index,
      "h12Item": h12Item,
      "tiktokItem": tiktokItem,
      "settingItem": settingItem,
      "exitItem": exitItem,
      "backgroundColor": backgroundColor?.value,
      "foregroundColor": foregroundColor?.value,
      "backgroundImage": backgroundImage,
      "bodyImage": bodyImage,
      "height": height,
      "width": width,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
