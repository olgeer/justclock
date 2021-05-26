// import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader {
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath) {
    return Future.value(mapLocales["zh_CH"]);
  }

  static const Map<String,dynamic> zh_CH = {
  "appName": "纯粹时钟",
  "copyright": "----- 纯粹时钟 v{}版 -----\nPowerby Max Olgeer.",
  "launch": {
    "forceUpgradeAlert": "新版本发布，由于安全考虑，此版本不能跳过。"
  },
  "clock": {
    "oclock": "{}点正",
    "halfPast": "{}点半",
    "oneQuarter": "{}点1刻",
    "threeQuarter": "{}点3刻",
    "normalAlert": "现在是 {}",
    "morningGreeting": "早起读书精神爽，现在是 {} 了",
    "workhardGreeting": "抓紧时间上班吧，已经 {} 了",
    "worktimeGreeting": "上班摸鱼可不是好习惯，现在是 {}",
    "lunchGreeting": "现在是 {}，赶紧吃饭去吧",
    "noonbreakGreeting": "现在是 {}，午休时间哦，眯一会儿吧",
    "offworkGreeting": "现在是 {}，总算下班了",
    "eveningGreeting": "只要不加班，快活到天亮，现在是 {}",
    "midnightGreeting": "夜猫子，不要看太晚了，已经 {} 了",
    "deepnightGreeting": "已经 {} 了，熬夜看书不是个好习惯，赶紧睡吧"
  }
};
static const Map<String,dynamic> en_US = {
  "appName": "JustClock",
  "copyright": "----- JustClock ver{} -----\nPowerby Max Olgeer.",
  "launch": {
    "forceUpgradeAlert": "New upgrade has found, for your device's safe, can not to skip."
  },
  "clock": {
    "oclock": "{} o'clock",
    "halfPast": "half past {}",
    "oneQuarter": "a quarter past {}",
    "threeQuarter": "a quarter to {}",
    "normalAlert": "Now is {}",
    "morningGreeting": "早起读书精神爽，现在是 {} 了",
    "workhardGreeting": "抓紧时间上班吧，已经 {} 了",
    "worktimeGreeting": "上班摸鱼可不是好习惯，现在是 {}",
    "lunchGreeting": "现在是 {}，赶紧吃饭去吧",
    "noonbreakGreeting": "现在是 {}，午休时间哦，眯一会儿吧",
    "offworkGreeting": "现在是 {}，总算下班了",
    "eveningGreeting": "只要不加班，快活到天亮，现在是 {}",
    "midnightGreeting": "夜猫子，不要看太晚了，已经 {} 了",
    "deepnightGreeting": "已经 {} 了，熬夜看书不是个好习惯，赶紧睡吧"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"zh_CH": zh_CH, "en_US": en_US};
}
