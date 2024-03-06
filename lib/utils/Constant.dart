import 'package:run_tracker/common/multiselectdialog/MultiSelectDialog.dart';
import 'package:intl/intl.dart';
import 'package:run_tracker/localization/locale_constant.dart';

class Constant {
  static const STR_BACK = "Back";
  static const STR_DELETE = "DELETE";
  static const STR_SETTING = "Setting";
  static const STR_SETTING_CIRCLE = "Setting_circle";
  static const STR_CLOSE = "CLOSE";
  static const STR_INFO = "INFO";
  static const STR_OPTIONS = "OPTIONS";

  static const STR_RUNNING_REMINDER = "STR_RUNNING_REMINDER";

  static const STR_RESET = "Reset";
  static const STR_EDIT_TARGET = "Edit target";
  static const STR_TURNOFF = "Turn off";

  static const ML_100 = 100;
  static const ML_150 = 150;
  static const ML_250 = 250;
  static const ML_500 = 500;

  static const MIN_KG = 20.00;
  static const MAX_KG = 997.00;

  static const MIN_LBS = 45.00;
  static const MAX_LBS = 2200.00;

  static List<MultiSelectDialogItem> daysList = [
    MultiSelectDialogItem("1", DateFormat.EEEE(getLocale().languageCode).dateSymbols.WEEKDAYS[0]),
    MultiSelectDialogItem("2", DateFormat.EEEE(getLocale().languageCode).dateSymbols.WEEKDAYS[1]),
    MultiSelectDialogItem("3", DateFormat.EEEE(getLocale().languageCode).dateSymbols.WEEKDAYS[2]),
    MultiSelectDialogItem("4", DateFormat.EEEE(getLocale().languageCode).dateSymbols.WEEKDAYS[3]),
    MultiSelectDialogItem("5", DateFormat.EEEE(getLocale().languageCode).dateSymbols.WEEKDAYS[4]),
    MultiSelectDialogItem("6", DateFormat.EEEE(getLocale().languageCode).dateSymbols.WEEKDAYS[5]),
    MultiSelectDialogItem("7", DateFormat.EEEE(getLocale().languageCode).dateSymbols.WEEKDAYS[6]),
  ];

  static const String EMAIL_PATH = 'Enter your email address here';

  static String getPrivacyPolicyURL() {
    return "https://sites.google.com/view/runtracker-pp/home";
  }

  static const String trackingStatus = "TrackingStatus.authorized";

}
