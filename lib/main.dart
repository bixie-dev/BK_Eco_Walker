import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:run_tracker/dbhelper/DataBaseHelper.dart';
import 'package:run_tracker/ui/drinkWaterScreen/DrinkWaterLevelScreen.dart';
import 'package:run_tracker/ui/home/HomeWizardScreen.dart';
import 'package:run_tracker/ui/mapsettings/MapSettingScreen.dart';
import 'package:run_tracker/ui/profile/ProfileScreen.dart';
import 'package:run_tracker/ui/profilesettings/ProfileSettingScreen.dart';
import 'package:run_tracker/ui/reminder/ReminderScreen.dart';
import 'package:run_tracker/ui/startRun/StartRunScreen.dart';
import 'package:run_tracker/ui/useLocation/UseLocationScreen.dart';
import 'package:run_tracker/ui/wellDoneScreen/WellDoneScreen.dart';
import 'package:run_tracker/ui/wizardScreen/WizardScreen.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';

import 'localization/locale_constant.dart';
import 'localization/localizations_delegate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preference().instance();
  await initPlugin();
  await DataBaseHelper().initialize();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationSubject.add(ReceivedNotification(
          id: id, title: title, body: body, payload: payload));
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse? notificationResponse) async {
    if (notificationResponse!.payload != null) {
      debugPrint(
          'notification notificationResponse: ${notificationResponse.payload}');
    }

    if (notificationResponse.payload != null &&
        notificationResponse.payload != Constant.STR_RUNNING_REMINDER) {
      Future.delayed(Duration(seconds: 1)).then((value) => Navigator.push(
          MyApp.navigatorKey.currentState!.overlay!.context,
          MaterialPageRoute(builder: (context) => DrinkWaterLevelScreen())));
    } else if (notificationResponse.payload != null &&
        notificationResponse.payload == Constant.STR_RUNNING_REMINDER) {
      Future.delayed(Duration(seconds: 1)).then((value) => Navigator.push(
          MyApp.navigatorKey.currentState!.overlay!.context,
          MaterialPageRoute(builder: (context) => StartRunScreen())));
    }

    selectedNotificationPayload = notificationResponse.payload;
    selectNotificationSubject.add(notificationResponse.payload);
  });

  _configureLocalTimeZone();

  runApp(MyApp());
}

Future<void> initPlugin() async {
  try {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      var _authStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      Preference.shared
          .setString(Preference.TRACK_STATUS, _authStatus.toString());
    }
  } on PlatformException {}

  final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
  Debug.printLog("UUID:" + uuid);
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

Future<InitializationStatus> _initGoogleMobileAds() {
  return MobileAds.instance.initialize();
}

class MyApp extends StatefulWidget {
  static final navigatorKey = new GlobalKey<NavigatorState>();

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  bool isFirstTimeUser = true;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    _locale = getLocale();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    //_initGoogleMobileAds();
    isFirstTime();
    super.initState();
  }

  isFirstTime() async {
    isFirstTimeUser =
        Preference.shared.getBool(Preference.IS_USER_FIRSTTIME) ?? true;
    Debug.printLog(isFirstTimeUser.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: MyApp.navigatorKey,
        builder: (context, child) {
          return MediaQuery(
            child: child!,
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          );
        },
        theme: ThemeData(
          splashColor: Colur.transparent,
          highlightColor: Colur.transparent,
          fontFamily: 'Roboto',
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: [
          Locale('en', ''),
          Locale('zh', ''),
          /*
          Locale('es', ''),
          Locale('de', ''),
          Locale('pt', ''),
          Locale('ar', ''),
          Locale('fr', ''),
          Locale('ja', ''),
          Locale('ru', ''),
          Locale('ur', ''),
          Locale('hi', ''),
          Locale('vi', ''),
          Locale('id', ''),
          Locale('bn', ''),
          Locale('ta', ''),
          Locale('te', ''),
          Locale('tr', ''),
          Locale('ko', ''),
          Locale('pa', ''),
          Locale('it', ''),
          Locale('sq', ''),
          Locale('az', ''),
          Locale('my', ''),
          Locale('hr', ''),
          Locale('cs', ''),
          Locale('nl', ''),
          Locale('el', ''),
          Locale('gu', ''),
          Locale('hu', ''),
          Locale('kn', ''),
          Locale('ml', ''),
          Locale('mr', ''),
          Locale('nb', ''),
          Locale('or', ''),
          Locale('fa', ''),
          Locale('pl', ''),
          Locale('ro', ''),
          Locale('sv', ''),
          Locale('th', ''),
          Locale('uk', ''),
          
           */
        ],
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode &&
                supportedLocale.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: Colur.white, brightness: Brightness.light),
          appBarTheme: AppBarTheme(
            backgroundColor: Colur.transparent,
          ),
        ),
        home: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colur.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colur.common_bg_dark,
          ),
          child: (isFirstTimeUser) ? WizardScreen() : HomeWizardScreen(),
        ),
        routes: <String, WidgetBuilder>{
          '/settingScreen': (BuildContext context) => MapSettingScreen(),
          '/startrunScreen': (BuildContext context) => StartRunScreen(),
          //'/wellDoneScreen': (BuildContext context) => WellDoneScreen(),
          '/profileScreen': (BuildContext context) => ProfileScreen(),
          '/homeWizardScreen': (BuildContext context) => HomeWizardScreen(),
          '/uselocationScreen': (BuildContext context) => UseLocationScreen(),
          '/drinkWaterLevelScreen': (BuildContext context) =>
              DrinkWaterLevelScreen(),
          '/profileSettingScreen': (BuildContext context) =>
              ProfileSettingScreen(),
          '/reminder': (BuildContext context) => ReminderScreen(),
        });
  }
}
