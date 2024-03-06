import 'package:flutter/material.dart';
import 'package:run_tracker/common/commonTopBar/CommonTopBar.dart';
import 'package:run_tracker/interfaces/TopBarClickListener.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/ui/drinkWaterReminder/DrinkWaterReminderScreen.dart';
import 'package:run_tracker/ui/runningReminder/RunningReminderScreen.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:intl/intl.dart';
import 'package:run_tracker/utils/Utils.dart';

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    implements TopBarClickListener {
  bool isRunningReminder = false;
  bool isDrinkWaterReminder = false;

  String txtReminderTime = "";
  String txtRepeatDay = "";

  String txtWaterReminder = "";
  late int drinkWaterInterval;

  @override
  void initState() {
    super.initState();
    fillData();
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
                  Languages.of(context)!.txtReminder,
                  this,
                  isShowBack: true,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Text(
                          Languages.of(context)!.txtRunningReminder,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colur.txt_white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> RunningReminder())).then((value) => fillData());
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colur.rounded_rectangle_color,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  txtReminderTime,
                                  style: TextStyle(
                                      color: Colur.txt_white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700),
                                ),
                                contentPadding: EdgeInsets.all(0.0),
                                trailing: Switch(
                                  value: isRunningReminder,
                                  activeColor: Colur.purple_gradient_color2,
                                  inactiveTrackColor: Colur.txt_grey,
                                  onChanged: (bool value) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> RunningReminder())).then((value) => fillData());
                                  },
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  Languages.of(context)!.txtRepeat,
                                  style: TextStyle(
                                      color: Colur.txt_white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5.0),
                                width: double.infinity,
                                child: Text(
                                  txtRepeatDay,
                                  style: TextStyle(
                                      color: Colur.txt_purple,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 25.0, bottom: 10.0),
                        child: Text(
                          Languages.of(context)!.txtDrinkWaterReminder,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colur.txt_white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> DrinkWaterReminderScreen())).then((value) => fillData());
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colur.rounded_rectangle_color,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  txtWaterReminder,
                                  style: TextStyle(
                                      color: Colur.txt_white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700),
                                ),
                                contentPadding: EdgeInsets.all(0.0),
                                trailing: Switch(
                                  value: isDrinkWaterReminder,
                                  activeColor: Colur.purple_gradient_color2,
                                  inactiveTrackColor: Colur.txt_grey,
                                  onChanged: (bool value) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> DrinkWaterReminderScreen())).then((value) => fillData());
                                  },
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  Languages.of(context)!.txtInterval,
                                  style: TextStyle(
                                      color: Colur.txt_white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5.0),
                                width: double.infinity,
                                child: Text(
                                  Utils.getIntervalString(context, drinkWaterInterval),
                                  style: TextStyle(
                                      color: Colur.txt_purple,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
    if(name == Constant.STR_BACK){
      Navigator.pop(context);
    }
  }

  void fillData() {
    String reminderTime =
        Preference.shared.getString(Preference.DAILY_REMINDER_TIME) ?? "6:30";
    isRunningReminder =
        Preference.shared.getBool(Preference.IS_DAILY_REMINDER_ON) ?? false;
    String? repeatDay =
    Preference.shared.getString(Preference.DAILY_REMINDER_REPEAT_DAY);
    List<dynamic> selectedDays = [];
    if (repeatDay!.isNotEmpty) {
      selectedDays.clear();
      selectedDays = repeatDay.split(",");
    }

    List<String> temp = [];
    selectedDays.forEach((element) {
      temp.add(Constant.daysList[int.parse(element as String) - 1].label!.substring(0, 3));
    });

    txtRepeatDay = temp.join(", ");

    var hr = int.parse(reminderTime.split(":")[0]);
    var min = int.parse(reminderTime.split(":")[1]);
    txtReminderTime =
        DateFormat.jm().format(DateTime(2021, 08, 1, hr, min));

    String prefStartTimeValue = Preference.shared.getString(Preference.START_TIME_REMINDER)??"08:00";
    String prefEndTimeValue = Preference.shared.getString(Preference.END_TIME_REMINDER)??"23:00";

    isDrinkWaterReminder = Preference.shared.getBool(Preference.IS_REMINDER_ON) ?? false;

    var hrs = int.parse(prefStartTimeValue.split(":")[0]);
    var mins = int.parse(prefStartTimeValue.split(":")[1]);
    var txtStart =
        DateFormat.jm().format(DateTime(2021, 08, 1, hrs, mins));

    var hre = int.parse(prefEndTimeValue.split(":")[0]);
    var mine = int.parse(prefEndTimeValue.split(":")[1]);
    var txtEnd =
    DateFormat.jm().format(DateTime(2021, 08, 1, hre, mine));

    txtWaterReminder = txtStart+" - "+txtEnd;
    drinkWaterInterval = Preference.shared.getInt(Preference.DRINK_WATER_INTERVAL) ?? 30;
    setState(() {
    });
  }
}
