import 'package:cron/cron.dart';
import 'package:justclock/pkg/logger.dart';
import 'package:justclock/pkg/sound.dart' as sound;
import 'package:justclock/pkg/vibrate.dart' as vibrate;
import 'package:justclock/widget/Toast.dart';

class AlarmClock {
  Cron cron;
  ScheduledTask alarmTask;

  ///报时计划
  Schedule alarmSchedule;
  actionCall alarmAction;

  ///免打搅时段，取消报时声音
  Schedule slientSchedule;

  ///允许休眠时段
  Schedule sleepSchedule;
  actionCall sleepEnableAction = () => null;
  actionCall sleepDisableAction = () => null;

  ///允许震动开关
  bool enableVibrate;

  ///允许报时音开关
  bool enableAlarmSound;

  ///刻钟报时音文件
  String quarterAlarmSound;
  int quarterSoundIdx;

  ///半点报时音文件
  String halfAlarmSound;
  int halfSoundIdx;

  ///整点报时音文件
  String oclockAlarmSound;
  int oclockSoundIdx;

  ///静音开关
  bool isSlient=false;

  String normalAlarmMessageTemplate = "现在是 {}";
  String anytimeTemplate = "{}点{}分";
  String halfPastTemplate = "{}点半";
  String oclockTemplate = "{}点正";
  String aQuarterTemplate = "{}点一刻";
  String threeQuarterTemplate = "{}点三刻";

  Map<String,Schedule> specialAlarms=Map<String,Schedule>();

  AlarmClock(
      {dynamic newSchedule,
      actionCall newAlarmAction,
      dynamic noSoundSchedule,
      dynamic noWakeLockSchedule,
      this.sleepEnableAction,
      this.sleepDisableAction,
      this.enableVibrate = true,
      this.enableAlarmSound = true,
      this.quarterAlarmSound,
      this.halfAlarmSound,
      this.oclockAlarmSound}) {
    if (newSchedule != null) {
      if (newSchedule is Schedule) alarmSchedule = newSchedule;
      if (newSchedule is String) alarmSchedule = Schedule.parse(newSchedule);
    } else {
      alarmSchedule = Schedule.parse("* 0,15,30,45 * * * *");
    }
    alarmAction = newAlarmAction ?? alarm;
    cron = Cron();
    alarmTask = cron.schedule(alarmSchedule, alarmAction);

    if (noSoundSchedule != null) {
      if (noSoundSchedule is Schedule) slientSchedule = noSoundSchedule;
      if (noSoundSchedule is String)
        slientSchedule = Schedule.parse(noSoundSchedule);
    }

    if (noWakeLockSchedule != null) {
      if (noWakeLockSchedule is Schedule) sleepSchedule = noWakeLockSchedule;
      if (noWakeLockSchedule is String)
        sleepSchedule = Schedule.parse(noWakeLockSchedule);
    }
    if (sleepSchedule?.match(DateTime.now()) == false){
      logger.fine("do wakelock");
      sleepDisableAction();
    }else{
      logger.fine("do not wakelock");
      sleepEnableAction();
    }

    if (enableVibrate) vibrate.init();
    
    if (enableAlarmSound) sound.init();

    initAsync();
  }

  void initAsync() async {
    if (enableAlarmSound) {
      oclockSoundIdx =
      await sound.loadSound(oclockAlarmSound ?? "assets/voices/座钟报时.mp3");
      halfSoundIdx =
      await sound.loadSound(halfAlarmSound ?? "assets/voices/短促欢愉.mp3");
      quarterSoundIdx =
      await sound.loadSound(quarterAlarmSound ?? "assets/voices/钟琴颤音.mp3");
    }

    // Uri uriRes=Uri.parse("http://olgeer.3322.org:8888/justclock/iphone.mp3");
    // logger.severe(uriRes.origin+uriRes.path);
    // await sound.play(await sound.loadSound(uriRes));
  }

  set newAlarmAction(actionCall action) {
    alarmTask?.cancel();
    alarmAction = action ?? alarmAction;
    alarmTask = cron.schedule(alarmSchedule, alarmAction);
  }

  set newSchedule(Schedule s) {
    alarmTask?.cancel();
    alarmSchedule = s;
    alarmTask = cron.schedule(alarmSchedule, alarmAction);
  }

  set setSlient(bool b){
    isSlient=b;
    logger.fine("isSlient is $b");
  }

  Schedule get newSchedule => alarmSchedule;

  set noSoundSchedule(Schedule s) => slientSchedule = s;
  Schedule get noSoundSchedule => slientSchedule;

  set noWakeLockSchedule(Schedule s) => sleepSchedule = s;
  Schedule get noWakeLockSchedule => sleepSchedule;

  String get alarmTemplate{
    String alarmTmp=normalAlarmMessageTemplate;
    if(specialAlarms.isNotEmpty){
      DateTime now=DateTime.now();

      specialAlarms.forEach((key, value) {
        if(value.match(now)){
          if(key.contains("{}"))alarmTmp=key;
          else alarmTmp="$key\n$alarmTmp";
        }
      });
    }
    return alarmTmp;
  }

  void addSpecialSchedule(Schedule s,String alarmTemplate){
    assert(s!=null && alarmTemplate!=null);
    specialAlarms.putIfAbsent(alarmTemplate, () => s);
  }

  void clearSpecialSchedule()=>specialAlarms.clear();

  void dispose() {
    sound.soundpool.dispose();
    sleepEnableAction();
    alarmTask.cancel();
  }

  void playSound(int soundIdx,{bool repeat,Duration duration}) {
    //仅设定时间段内报时
    if (!(slientSchedule?.match(DateTime.now()) ?? false) && !isSlient) {
      sound.play(soundIdx,repeat: repeat??duration!=null,duration: duration);
    }
  }

  void alarm() {
    var now = DateTime.now();
    sleepDisableAction();
    String alertMsg = this.alarmTemplate;
    String alertTime;
    switch (now.minute) {
      case 30:
        alertTime = halfPastTemplate.tr(args: [now.hour.toString()]);
        playSound(halfSoundIdx,repeat: true,duration:Duration(seconds: 3));
        vibrate.mediumVibrate();
        break;
      case 0:
        alertTime = oclockTemplate.tr(args: [now.hour.toString()]);
        playSound(oclockSoundIdx,repeat: true,duration:Duration(seconds: 10));
        vibrate.longVibrate();
        break;
      case 15:
        alertTime = aQuarterTemplate.tr(args: [now.hour.toString()]);
        playSound(quarterSoundIdx,repeat: true,duration:Duration(seconds: 2));
        vibrate.littleShake();
        break;
      case 45:
        alertTime = threeQuarterTemplate.tr(args: [now.hour.toString()]);
        playSound(quarterSoundIdx,repeat: true,duration:Duration(seconds: 2));
        vibrate.littleShake();
        break;
      default:
        alertTime =
            anytimeTemplate.tr(args: [now.hour.toString(), now.minute.toString()]);
        playSound(quarterSoundIdx);
        break;
    }

    //按休眠计划改变激活锁定状态
    if (sleepSchedule?.match(now)==false) {
      sleepDisableAction();
    } else {
      sleepEnableAction();
    }

    showToast(alertMsg.tr(args: [alertTime]));
  }
}

typedef actionCall = Function();

extension MatchExtension on Schedule {
  bool match(DateTime now) {
    if (this?.seconds?.contains(now.second) == false) return false;
    if (this?.minutes?.contains(now.minute) == false) return false;
    if (this?.hours?.contains(now.hour) == false) return false;
    if (this?.days?.contains(now.day) == false) return false;
    if (this?.months?.contains(now.month) == false) return false;
    if (this?.weekdays?.contains(now.weekday) == false) return false;
    return true;
  }
}

extension TranslateExtension on String {
  String tr({List<String> args}) {
    String tmp = this;
    while (tmp.contains("{}") && !(args?.isEmpty ?? true)) {
      tmp = tmp.replaceFirst("{}", args.removeAt(0));
    }
    return tmp;
  }
}
