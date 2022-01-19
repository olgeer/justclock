library justclock;
// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:justclock/clock_component.dart';
import 'package:justclock/config/init.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await preProcess();
  runApp(MyApp());
      // EasyLocalization(
      // child: MyApp(),
      // supportedLocales: [Locale('zh', 'CH'), Locale('en', 'US')],
      // path: 'translations',
      // fallbackLocale: Locale('en', 'US'),
      // // fallbackLocale: Locale('zh', 'CH'),
      // // startLocale: Locale('zh', 'CH'), //set chinese is default
      // // saveLocale: false,
      // // useOnlyLangCode: true,
      // // preloaderColor: Colors.black,
      // // preloaderWidget: CustomPreloaderWidget(),
      //
      // // optional assetLoader default used is RootBundleAssetLoader which uses flutter's assetloader
      // // install easy_localization_loader for enable custom loaders
      // // assetLoader: RootBundleAssetLoader()
      // // assetLoader: HttpAssetLoader()
      // // assetLoader: FileAssetLoader()
      // // assetLoader: JsonAssetLoader()
      // // assetLoader: YamlAssetLoader() //multiple files
      // // assetLoader: YamlSingleAssetLoader() //single file
      // // assetLoader: XmlAssetLoader() //multiple files
      // // assetLoader: XmlSingleAssetLoader() //single file
      // assetLoader: CodegenLoader()));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JustClock',
      // localizationsDelegates: [
      //   EasyLocalization.of(context).delegate,
      // ],
      // supportedLocales: EasyLocalization.of(context).supportedLocales,
      // locale: EasyLocalization.of(context).locale,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ClockComponent(),
      builder: EasyLoading.init(),
    );
  }
}
