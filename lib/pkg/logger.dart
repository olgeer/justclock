import 'dart:io';
import 'package:justclock/config/application.dart';
import 'package:log_4_dart_2/log_4_dart_2.dart';

var config = {
  'appenders': [
    {
      'type': 'CONSOLE',
      'dateFormat': 'yyyy-MM-dd HH:mm:ss',
      'format': '%d %i %t %l %m',
      'level': 'DEBUG'
    },
    {
      'type': 'FILE',
      'dateFormat': 'yyyy-MM-dd HH:mm:ss',
      'format': '%d %i %t %l %m',
      'level': 'DEBUG',
      'filePattern': 'justclock_log',
      'fileExtension': 'txt',
      'path': '${Application.appRootPath}/log/',
      'rotationCycle': 'WEEK'
    },
    // {
    //   'type': 'EMAIL',
    //   'dateFormat': 'yyyy-MM-dd HH:mm:ss',
    //   'level': 'INFO',
    //   'host': 'smtp.test.de',
    //   'user': 'test@test.de',
    //   'password': 'test',
    //   'port': 1,
    //   'fromMail': 'test@test.de',
    //   'fromName': 'Jon Doe',
    //   'to': ['test1@example.com', 'test2@example.com'],
    //   'toCC': ['test1@example.com', 'test2@example.com'],
    //   'toBCC': ['test1@example.com', 'test2@example.com'],
    //   'ssl': true,
    //   'templateFile': '/path/to/template.txt',
    //   'html': false
    // },
    // {
    //   'type': 'HTTP',
    //   'dateFormat': 'yyyy-MM-dd HH:mm:ss',
    //   'level': 'INFO',
    //   'url': 'api.example.com',
    //   'headers': ['Content-Type:application/json']
    // },
    // {
    //   'type': 'MYSQL',
    //   'level': 'INFO',
    //   'host': 'database.example.com',
    //   'user': 'root',
    //   'password': 'test',
    //   'port': 1,
    //   'database': 'mydatabase',
    //   'table': 'log_entries'
    // }
  ]
};

void initLogger(){
  Directory logDir=Directory('${Application.appRootPath}/log/');
  if(!logDir.existsSync()){
    logDir.createSync(recursive: true);
  }
  Logger().init(config);
}