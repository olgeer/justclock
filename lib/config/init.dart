import 'package:justclock/pkg/utils.dart';
import 'package:justclock/config/application.dart';
import 'package:justclock/config/constants.dart';
import 'package:justclock/config/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:base_utility/base_utility.dart';

//App启动前预处理
Future preProcess() async {
  Application.appRootPath = await initPath();
  Application.cache = await SharedPreferences.getInstance();

  //设置显示日志的详细程度
  initLogger(logLevel: Level.FINER);

  Setting.loadSetting();
  // print(Setting.toJson());

  Application.defaultSkin=Application.cache.getString(DefaultSkin);
}


