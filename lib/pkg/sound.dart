
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

final Map<String,String> effectVoice={
  "玻璃撞击声":"玻璃撞击声.mp3",
  "短促喇叭声":"短促喇叭声.mp3",
  "座钟报时":"座钟报时.mp3"
};

Soundpool soundpool;

void init()async {
  soundpool=Soundpool(maxStreams: 1,);
  // print(await soundpool.load(await rootBundle.load("assets/voices/${effectVoice["玻璃撞击声"]}")));
  // print(await soundpool.load(await rootBundle.load("assets/voices/${effectVoice["短促喇叭声"]}")));
  // print(await soundpool.load(await rootBundle.load("assets/voices/${effectVoice["座钟报时"]}")));
}