import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:run_tracker/common/commonTopBar/CommonTopBar.dart';
import 'package:run_tracker/common/multiselectdialog/MultiSelectDialog.dart';
import 'package:run_tracker/custom/GradientButtonSmall.dart';
import 'package:run_tracker/interfaces/TopBarClickListener.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/main.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:intl/intl.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:timezone/timezone.dart' as tz;

class RunningReminder extends StatefulWidget {
  const RunningReminder({Key? key}) : super(key: key);

  @override
  _RunningReminderState createState() => _RunningReminderState();
}

class _RunningReminderState extends State<RunningReminder>
    implements TopBarClickListener {
  bool isReminderOn = false;
  TextEditingController timeController = TextEditingController();
  TextEditingController repeatController = TextEditingController();
  late TimeOfDay selectedTime;

  List<MultiSelectDialogItem> daysList = Constant.daysList;

  List<dynamic> selectedDays = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
  ];

  @override
  void initState() {
    String reminderTime =
        Preference.shared.getString(Preference.DAILY_REMINDER_TIME) ?? "6:30";
    isReminderOn =
        Preference.shared.getBool(Preference.IS_DAILY_REMINDER_ON) ?? false;
    String? repeatDay =
    Preference.shared.getString(Preference.DAILY_REMINDER_REPEAT_DAY);

    if (repeatDay!.isNotEmpty) {
      selectedDays.clear();
      selectedDays = repeatDay.split(",");
    }

    List<String> temp = [];
    selectedDays.forEach((element) {
      temp.add(
          daysList[int.parse(element as String) - 1].label!.substring(0, 3));
    });

    repeatController.text = temp.join(", ");

    var hr = int.parse(reminderTime.split(":")[0]);
    var min = int.parse(reminderTime.split(":")[1]);
    selectedTime = TimeOfDay(hour: hr, minute: min);
    timeController.text = DateFormat.jm().format(DateTime(DateTime.now().year,
        DateTime.now().month, DateTime.now().day, hr, min));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colur.common_bg_dark,
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                Container(
                  child: CommonTopBar(
                    Languages.of(context)!.txtRunningReminder,
                    this,
                    isShowBack: true,
                  ),
                ),
                Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                    Languages.of(context)!.txtDailyReminder,
                                    style: TextStyle(
                                        color: Colur.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  )),
                              Switch(
                                onChanged: (bool value) async {
                                  var status = await Permission.notification.status;
                                  if (status.isDenied) {
                                    await Permission.notification.request();
                                  }

                                  if (status.isPermanentlyDenied) {
                                    openAppSettings();
                                  }

                                  if (isReminderOn == false) {
                                    setState(() {
                                      isReminderOn = true;
                                    });
                                  } else {
                                    setState(() {
                                      isReminderOn = false;
                                    });
                                  }
                                },
                                value: isReminderOn,
                                activeColor: Colur.purple_gradient_color2,
                                inactiveTrackColor: Colur.txt_grey,
                              )
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              showTimePickerDialog(context);
                            },
                            child: Container(
                              child: Row(
                                children: [
                                  Text(
                                    timeController.text,
                                    style: TextStyle(
                                        color: Colur.txt_purple,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colur.txt_purple,
                                    size: 25,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                color: Colur.gray_border,
                              )),
                          Text(
                            Languages.of(context)!.txtRepeat,
                            style: TextStyle(
                                color: Colur.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                          InkWell(
                            onTap: () {
                              showDaySelectionDialog(context);
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      repeatController.text,
                                      style: TextStyle(
                                          color: Colur.txt_purple,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colur.txt_purple,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                color: Colur.gray_border,
                              )),
                        ],
                      ),
                    )),
                Container(
                  margin: EdgeInsets.only(bottom: 30.0),
                  child: GradientButtonSmall(
                    width: 250,
                    height: 50,
                    radius: 30.0,
                    child: Text(
                      Languages.of(context)!.txtSave,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colur.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colur.purple_gradient_color1,
                        Colur.purple_gradient_color2,
                      ],
                    ),
                    onPressed: () {
                      saveReminder();
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }

  showTimePickerDialog(BuildContext context) async {
    final TimeOfDay? picked = (await showTimePicker(
      context: context,
      initialTime: selectedTime,
    ));

    if (picked != null) {
      selectedTime = picked;
      timeController.text = DateFormat.jm().format(
          DateTime(2021, 08, 1, selectedTime.hour, selectedTime.minute));
      setState(() {});
    }
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
    if (name == Constant.STR_BACK) {
      Navigator.of(context).pop();
    }
  }

  void showDaySelectionDialog(BuildContext context) async {
    List? selectedValues = await showDialog<List>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          title: Text(
            Languages.of(context)!.txtRepeat,
            style: TextStyle(
                color: Colur.txt_black,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          okButtonLabel: Languages.of(context)!.txtOk,
          cancelButtonLabel: Languages.of(context)!.txtCancel,
          items: daysList,
          initialSelectedValues: selectedDays,
          labelStyle: TextStyle(
              color: Colur.txt_black,
              fontSize: 16,
              fontWeight: FontWeight.w400),
          dialogShapeBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0)),
          ),
          checkBoxActiveColor: Colur.txt_purple,
          minimumSelection: 1,
        );
      },
    );

    selectedDays.clear();
    selectedDays = selectedValues!;
    repeatController.text = "";
    selectedDays.sort(
            (a, b) => int.parse(a as String).compareTo(int.parse(b as String)));
    List<String> temp = [];
    selectedDays.forEach((element) {
      temp.add(
          daysList[int.parse(element as String) - 1].label!.substring(0, 3));
    });

    repeatController.text = temp.join(",");
  
    setState(() {});
  }

  Future<void> saveReminder() async {
    Preference.shared.setString(Preference.DAILY_REMINDER_TIME,
        "${selectedTime.hour}:${selectedTime.minute}");
    Preference.shared.setBool(Preference.IS_DAILY_REMINDER_ON, isReminderOn);
    Preference.shared.setString(
        Preference.DAILY_REMINDER_REPEAT_DAY, selectedDays.join(","));

    int notificationId = 100;

    List<PendingNotificationRequest> pendingNoti =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    pendingNoti.forEach((element) {
      if (element.payload == Constant.STR_RUNNING_REMINDER) {
        Debug.printLog(
            "Cancele Notification ::::::==> ${element.id}");
        flutterLocalNotificationsPlugin.cancel(element.id);
      }
    });

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
        now.day, selectedTime.hour, selectedTime.minute);

    if (isReminderOn) {
      selectedDays.forEach((element) async {
        notificationId += 1;
        if (int.parse(element as String) == DateTime.now().weekday &&
            DateTime.now().isBefore(scheduledDate)) {
          await scheduledNotification(scheduledDate, notificationId);
        } else {
          var tempTime = scheduledDate.add(const Duration(days: 1));
          while (tempTime.weekday != int.parse(element)) {
            tempTime = tempTime.add(const Duration(days: 1));
          }
          await scheduledNotification(tempTime, notificationId);
        }
      });
    }
    Navigator.pop(context);
  }

  scheduledNotification(tz.TZDateTime scheduledDate, int notificationId) async {
    Debug.printLog(
        "Schedule Notification at ::::::==> ${scheduledDate.toIso8601String()}");
    Debug.printLog(
        "Schedule Notification at scheduledDate.millisecond::::::==> $notificationId");

    var titleText = Languages.of(context)!.txtRunningReminder;
    var msg = Languages.of(context)!.txtRunningReminderMsg;

    await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        titleText,
        msg,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'running_reminder_tracker',
              'Running Reminder',
              channelDescription: 'This is reminder for running',icon: 'ic_notification'),
          iOS: DarwinNotificationDetails()
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,payload: Constant.STR_RUNNING_REMINDER);
  }
}
