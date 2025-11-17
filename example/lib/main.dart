import 'dart:async';
import 'dart:developer';

import 'package:example_flutter/colors.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'package:example_flutter/page/config.dart';
import 'package:example_flutter/page/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      //     overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark));


      runApp(const MyApp());
    },
    (error, stackTrace) => log(
      error.toString(),
      stackTrace: stackTrace,
      name: 'runZonedGuarded OnError',
    ),
  );
  // runZonedGuarded(() async {
  // }, (error, stackTrace) {
  //   // Ошибки виджетов (необработанные)
  //   log('!!!*** runZonedGuarded.onError: ${error.toString()}');
  // });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription? _linkSub;

  @override
  void initState() {
    _firebaseInit();
    _handleInitialLink();
    _handleIncomingLinks();
    super.initState();
  }

  Future<void> _firebaseInit() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on PlatformException catch (err) {
      // ignore: avoid_print
      print('firebaseInit: $err');
    }
  }

  Future<void> _handleInitialLink() async {
    try {
      final initialLink = await AppLinks().getInitialLink();
      if (initialLink != null) {
        _showSnackBarMessage('App opened with link: $initialLink');
      }
    } on PlatformException catch (err) {
      // ignore: avoid_print
      print('initialLink: $err');
    }
  }

  void _handleIncomingLinks() {
    _linkSub = AppLinks().stringLinkStream.listen((String link) {
      _showSnackBarMessage('App resumed with link: $link');
    }, onError: (err) {
      _showSnackBarMessage('App resume with link failed: $err');
    });
  }

  void _showSnackBarMessage(String text) {
    final snackBar = SnackBar(content: Text(text));
    _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData(
        // useMaterial3: true,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.white, // Color of the progress indicator
          // linearTrackColor: AppColors.accentDark, // Color of the linear track
          circularTrackColor: AppColors.primary, // Color of the circular track
          strokeWidth: 4.0, // Thickness of the circular indicator
          strokeCap: StrokeCap.round, // Rounded ends for circular indicator
        ),
        colorScheme: const ColorScheme.light(
          surface: AppColors.background,
          primary: AppColors.primary,
          secondary: AppColors.accentLight,
          onSurface: AppColors.white,
          outline: AppColors.primary,
        ),
      ),
      home: Builder(
        builder: (context) => ConfigPage(
          doneCallback: (config) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(config: config),
              ),
              (route) => false,
            );
          },
        ),
      ),
      builder: (context, child) => child!,
    );
  }
}
