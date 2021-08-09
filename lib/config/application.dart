import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//全局变量
class Application {
  static late SharedPreferences cache;
  static String? defaultSkin;
  static late String appRootPath;
  static late Size screenSize;

  static bool stopListen=false;
  static bool isDark=false;
  static bool needReload=true;
  ///系统屏幕旋转同步开关
  static bool canRotate=false;
  ///oled屏幕防烧屏开关
  static bool oledAntiBurn = true;
  ///正点报时开关
  static bool alertAtHour = true;
  ///自动同步更新书籍
  static bool autoUpdate = true;
  ///是否允许使用闪光灯提醒
  static bool useLamp = true;
  ///每次启动软件时只进行一次
  static bool isUpdated = false;

  static bool isQuarterAlarm=true;
  static bool isHalfAlarm=true;
  static bool isHourAlarm=true;

  static bool showIntro=true;
  static bool appCanUpgrade=false;
  static bool hasVibrator=false;
  static bool hasAmplitudeControl=false;
  static bool hasCustomVibrationsSupport=false;
  static bool hasLamp=false;
  static bool comfortableGreeting=true;
}
