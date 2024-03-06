import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:run_tracker/ad_helper.dart';
import 'package:run_tracker/common/commonTopBar/CommonTopBar.dart';
import 'package:run_tracker/custom/waterLevel/Liquid_progress_indicator.dart';
import 'package:run_tracker/dbhelper/DataBaseHelper.dart';
import 'package:run_tracker/dbhelper/datamodel/WaterData.dart';
import 'package:run_tracker/interfaces/TopBarClickListener.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/localization/locale_constant.dart';
import 'package:run_tracker/main.dart';
import 'package:run_tracker/ui/drinkWaterSettings/DrinkWaterSettingsScreen.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';

class DrinkWaterLevelScreen extends StatefulWidget {
  @override
  _DrinkWaterLevelScreenState createState() => _DrinkWaterLevelScreenState();
}

class _DrinkWaterLevelScreenState extends State<DrinkWaterLevelScreen>
    implements TopBarClickListener {
  var fullHeight;
  var fullWidth;

  int? drinkWater;
  int? maxLimitOfDrinkWater;
  int? num;
  int? valueForIncrement;

  int touchedIndexForWaterChart = -1;

  var currentDate = DateTime.now();
  var currentDay = DateFormat('EEEE',getLocale().languageCode).format(DateTime.now());
  var startDateOfCurrentWeek;
  var endDateOfCurrentWeek;
  var formatStartDateOfCurrentWeek;
  var formatEndDateOfCurrentWeek;

  var prefTargetValue;
  var prefSelectedML;
  int? prefSelectedDay;

  List<WaterData> drinkWaterHistory = [];
  DateTime? nextDrinkTime;

  List<String> allDays = DateFormat.EEEE(getLocale().languageCode).dateSymbols.SHORTWEEKDAYS;

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    _getPreference();
    _getDataFromDataBase();


    startDateOfCurrentWeek =
        getDate(currentDate.subtract(Duration(days: currentDate.weekday - prefSelectedDay!)));
    if(prefSelectedDay == 0){
      endDateOfCurrentWeek = getDate(currentDate.add(Duration(
          days: DateTime.daysPerWeek - 4)));
    }else if(prefSelectedDay == 1){
      endDateOfCurrentWeek = getDate(currentDate.add(Duration(
          days: DateTime.daysPerWeek - currentDate.weekday)));
    }else if(prefSelectedDay == -1){
      endDateOfCurrentWeek = getDate(currentDate.add(Duration(
          days: DateTime.daysPerWeek - 5)));
    }
    formatStartDateOfCurrentWeek =
        DateFormat.MMMd(getLocale().languageCode).format(startDateOfCurrentWeek);
    formatEndDateOfCurrentWeek =
        DateFormat.MMMd(getLocale().languageCode).format(endDateOfCurrentWeek);
    _loadBanner();
    super.initState();
  }

  _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(
          nonPersonalizedAds: Utils.nonPersonalizedAds()
      ),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  _getPreference() {
    prefTargetValue =
        Preference.shared.getString(Preference.TARGET_DRINK_WATER);
    prefSelectedML =
        Preference.shared.getInt(Preference.SELECTED_DRINK_WATER_ML);
    prefSelectedDay =
        Preference.shared.getInt(Preference.FIRST_DAY_OF_WEEK_IN_NUM) ?? 1;
    setState(() {
      if (prefTargetValue == null) {
        maxLimitOfDrinkWater = 2000;
      } else {
        maxLimitOfDrinkWater = int.parse(prefTargetValue);
      }

      if (prefSelectedML == null) {
        num = 1;
      } else {
        num = prefSelectedML;
      }
    });
  }

  _getDataFromDataBase() async {
    drinkWater = await DataBaseHelper
        .getTotalDrinkWater(DateFormat.yMd().format(currentDate).toString());
    drinkWaterHistory =
        await DataBaseHelper().selectTodayDrinkWater(Utils.getCurrentDate());
    _getChartDataForDrinkWater();
    _getDailyDrinkWaterAverage();
    List<PendingNotificationRequest> notificationList =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    List<PendingNotificationRequest> todayList = [];

    notificationList.forEach((element) {

      if (element.payload != Constant.STR_RUNNING_REMINDER) {
        DateTime scheduleTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(element.payload!));
        DateTime currTime = DateTime.now();

        if (currTime.day == scheduleTime.day &&
            currTime.month == scheduleTime.month &&
            currTime.year == currTime.year) {
          if (scheduleTime.isAfter(currTime)) todayList.add(element);
        }
      }
    });

    if (todayList.isNotEmpty) {
      todayList.sort(
          (a, b) => int.parse(a.payload!).compareTo(int.parse(b.payload!)));
      nextDrinkTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(todayList[0].payload!));

      Debug.printLog(
          "nextDrinkTime Notification Time" + nextDrinkTime!.toIso8601String());
    }
    setState(() {});
  }

  List<WaterData>? total;
  Map<String, int> map = {};

  _getChartDataForDrinkWater() async {
    List<String> dates = [];
    allDays = [];
    for (int i = 0; i <= 6; i++) {
      var currentWeekDates = getDate(DateTime.now()
          .subtract(Duration(days: currentDate.weekday - prefSelectedDay!))
          .add(Duration(days: i)));
      String formatCurrentWeekDates = DateFormat.yMd().format(currentWeekDates);
      allDays.add(DateFormat('EEEE',getLocale().languageCode).format(currentWeekDates));
      dates.add(formatCurrentWeekDates);
    }
    total = await DataBaseHelper.getTotalDrinkWaterAllDays(dates);
    map.clear();
    for (int i = 0; i < dates.length; i++) {
      bool isMatch = false;
      total!.forEach((element) {
        if (element.date == dates[i]) {
          map.putIfAbsent(element.date!, () => element.total!);
          isMatch = true;
        }
      });
      if (!isMatch) map.putIfAbsent(dates[i], () => 0);
    }
    setState(() {});
  }

  String? drinkWaterAverage;

  _getDailyDrinkWaterAverage() async {
    List<String> dates = [];
    for (int i = 0; i <= 6; i++) {
      var currentWeekDates = getDate(DateTime.now()
          .subtract(Duration(days: currentDate.weekday - 1))
          .add(Duration(days: i)));
      String formatCurrentWeekDates = DateFormat.yMd().format(currentWeekDates);
      dates.add(formatCurrentWeekDates);
    }
    int? average = await DataBaseHelper.getTotalDrinkWaterAverage(dates);
    drinkWaterAverage = (average! ~/ 7).toString();
    setState(() {});
    Debug.printLog("drinkWaterAverage =====>" + drinkWaterAverage!);
  }

  @override
  Widget build(BuildContext context) {
    fullHeight = MediaQuery.of(context).size.height;
    fullWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colur.common_bg_dark,
      body: Column(
        children: [
          Container(
            child: CommonTopBar(
              Languages.of(context)!.txtToday,
              this,
              subHeader: Languages.of(context)!.txtDrinkWater,
              isShowSubheader: true,
              isShowBack: true,
              isShowSettingCircle: true,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _waterProgressIndicator(fullHeight, fullWidth),
                  _designForWaterIncrementButton(fullHeight, fullWidth),
                  _designForWaterMeasureIcon(fullHeight, fullWidth),
                  _designWeek(fullHeight, fullWidth),
                  _drinkWaterWidget(context),
                  _todayHistory(fullHeight, fullWidth),
                  _reminderHistory(fullHeight, fullWidth),
                  _todayDrinkWaterHistory(fullHeight, fullWidth, context),
                ],
              ),
            ),
          ),

          if (_isBannerAdReady)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),

        ],
      ),
    );
  }

  _waterProgressIndicator(double fullheight, double fullwidth) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 250,
      width: 250,
      child: LiquidCircularProgressIndicator(
          value: drinkWater != null
              ? (drinkWater! / maxLimitOfDrinkWater!).toDouble()
              : 0,
          valueColor: AlwaysStoppedAnimation(Colur.water_level_wave2),
          backgroundColor: Colur.common_bg_dark,
          borderColor: Colur.rounded_rectangle_color,
          borderWidth: 5.0,
          direction: Axis.vertical,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 10.0),
                height: 60,
                child: Image.asset(
                  'assets/icons/ic_bottle.png',
                  scale: 4.0,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        drinkWater != null
                            ? drinkWater.toString()
                            : 0.toString(),
                        style: TextStyle(
                          color: Colur.txt_white,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "/" + maxLimitOfDrinkWater.toString(),
                        style: TextStyle(
                          color: Colur.txt_white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  _designForWaterIncrementButton(double fullheight, double fullwidth) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: Image.asset(
              'assets/icons/water/ic_up_arrow.png',
              scale: 2.6,
            ),
          ),
          InkWell(
            onTap: () {
              (drinkWater != null)
                  ? drinkWater = drinkWater! + valueForIncrement!
                  : drinkWater = 0;
              Debug.printLog(
                  "Plus Water drinkWater ==> " + valueForIncrement.toString());

              DataBaseHelper()
                  .insertDrinkWater(WaterData(
                    id: null,
                    ml: valueForIncrement,
                    date: Utils.getCurrentDate(),
                    time: Utils.getCurrentDayTime(),
                    dateTime: Utils.getCurrentDateTime(),
                  ))
                  .then((value) => {
                        drinkWaterHistory.clear(),
                        _getDataFromDataBase(),
                        _getChartDataForDrinkWater(),
                        setState(() {})
                      });
            },
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                _selectedCommonIcon(fullheight, fullwidth, num!),
                scale: 3.5,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Text(
              valueForIncrement.toString() + " " + Languages.of(context)!.txtMl,
              style: TextStyle(
                  color: Colur.txt_grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  _designForWaterMeasureIcon(double fullheight, double fullwidth) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                num = 1;
                Preference.clearSelectedDrinkWaterML();
                Preference.shared
                    .setInt(Preference.SELECTED_DRINK_WATER_ML, num!);
                Debug.printLog("Value ==> $num");
              });
            },
            child: Container(
              child: Image.asset(
                (num == 1)
                    ? 'assets/icons/water/ic_fill_100.png'
                    : 'assets/icons/water/ic_empty_100.png',
                scale: 3.5,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                num = 2;
                Preference.clearSelectedDrinkWaterML();
                Preference.shared
                    .setInt(Preference.SELECTED_DRINK_WATER_ML, num!);
                Debug.printLog("Value ==> $num");
              });
            },
            child: Container(
              child: Image.asset(
                (num == 2)
                    ? 'assets/icons/water/ic_fill_150.png'
                    : 'assets/icons/water/ic_empty_150.png',
                scale: 3.5,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                num = 3;
                Preference.clearSelectedDrinkWaterML();
                Preference.shared
                    .setInt(Preference.SELECTED_DRINK_WATER_ML, num!);
                Debug.printLog("Value ==> $num");
              });
            },
            child: Container(
              child: Image.asset(
                (num == 3)
                    ? 'assets/icons/water/ic_fill_250.png'
                    : 'assets/icons/water/ic_empty_250.png',
                scale: 3.5,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                num = 4;
                Preference.clearSelectedDrinkWaterML();
                Preference.shared
                    .setInt(Preference.SELECTED_DRINK_WATER_ML, num!);
                Debug.printLog("Value ==> $num");
              });
            },
            child: Container(
              child: Image.asset(
                (num == 4)
                    ? 'assets/icons/water/ic_fill_500.png'
                    : 'assets/icons/water/ic_empty_500.png',
                scale: 3.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _designWeek(double fullheight, double fullwidth) {
    return Container(
      child: Column(
        children: [
          Text(
            Languages.of(context)!.txtWeek,
            style: TextStyle(
              color: Colur.txt_white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: Colur.water_level_wave1,
            ),
          )
        ],
      ),
    );
  }

  _drinkWaterWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      margin: const EdgeInsets.only(top: 25.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 20.0),
            child: Text(
              formatStartDateOfCurrentWeek.toString() +
                  " - " +
                  formatEndDateOfCurrentWeek.toString(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colur.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 15.5),
            ),
          ),
          Container(
            height: 200,
            margin: const EdgeInsets.only(
              top: 30.0,
            ),
            width: double.infinity,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colur.txt_grey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String weekDay;
                        if (allDays.isNotEmpty) {
                          weekDay = allDays[groupIndex.toInt()];
                        } else {
                          weekDay = "";
                        }
                        return BarTooltipItem(
                          weekDay + '\n',
                          TextStyle(
                            color: Colur.txt_white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (rod.toY.toInt() - 1).toString(),
                              style: TextStyle(
                                color: Colur.txt_white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        touchedIndexForWaterChart = -1;
                        return;
                      }
                      touchedIndexForWaterChart =
                          barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                gridData: FlGridData(
                  show: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        var style, text;
                        if (allDays.isNotEmpty) {
                          if (allDays[value.toInt()] == currentDay) {
                            style =  _selectedTextStyle();
                          } else {
                            style =  _unSelectedTextStyle();
                          }
                        } else {
                          style =  _unSelectedTextStyle();
                        }
                        if (allDays.isNotEmpty) {
                          if (allDays[value.toInt()] == currentDay) {
                            text = Languages.of(context)!.txtToday;
                          } else {
                            text = allDays[value.toInt()].substring(0, 3);
                          }
                        } else {
                          text = "";
                        }

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(text, style: style),
                        );

                      },
                    ),
                  ),
                  topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      )),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: showingDrinkWaterGroups(),
              ),
              swapAnimationCurve: Curves.ease,
              swapAnimationDuration: Duration(seconds: 0),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 20.0),
            child: Text(
              drinkWaterAverage != null
                  ? Languages.of(context)!.txtWeeklyAverage +
                  " : " +
                  drinkWaterAverage! +
                  " " +
                  Languages.of(context)!.txtMl
                  : Languages.of(context)!.txtWeeklyAverage +
                  " :0 " +
                  Languages.of(context)!.txtMl,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colur.graph_water,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.5),
            ),
          ),
        ],
      ),
    );
  }

  _selectedTextStyle() {
    return const TextStyle(
        color: Colur.txt_white, fontWeight: FontWeight.w400, fontSize: 14);
  }

  _unSelectedTextStyle() {
    return const TextStyle(
        color: Colur.txt_grey, fontWeight: FontWeight.w400, fontSize: 14);
  }

  BarChartGroupData makeDrinkWaterGroupData(
      int x,
      double y, {
        bool isTouched = false,
        Color barColor = Colur.graph_water,
        double width = 40,
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          gradient: LinearGradient(colors: isTouched ? [Colur.white,Colur.white,] : [barColor,barColor],),
          width: width,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
              topLeft: Radius.circular(3.0),
              topRight: Radius.circular(3.0)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxLimitOfDrinkWater!.toDouble(),
            gradient: LinearGradient(colors: [Colur.rounded_rectangle_color,Colur.rounded_rectangle_color],),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> showingDrinkWaterGroups() {
    List<BarChartGroupData> list = [];

    for (int i = 0; i < map.length; i++) {
      list.add(makeDrinkWaterGroupData(
          i, map.entries.toList()[i].value.toDouble(),
          isTouched: i == touchedIndexForWaterChart));
    }

    return list;
  }

  _todayHistory(double fullheight, double fullwidth) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 50, right: 20),
      child: Row(
        children: [
          Container(
            child: Text(
              Languages.of(context)!.txtTodayRecords,
              style: TextStyle(
                color: Colur.txt_white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        ],
      ),
    );
  }

  _selectedCommonIcon(double fullheight, double fullwidth, int num) {
    switch (num) {
      case 1:
        valueForIncrement = 100;
        return 'assets/icons/water/ic_fill_plus_100.webp';
      case 2:
        valueForIncrement = 150;
        return 'assets/icons/water/ic_fill_plus_150.png';
      case 3:
        valueForIncrement = 250;
        return 'assets/icons/water/ic_fill_plus_250.webp';
      case 4:
        valueForIncrement = 500;
        return 'assets/icons/water/ic_fill_plus_500.webp';
      default:
        return Utils.showToast(context, "Something Went Wrong in Switch");
    }
  }

  _reminderHistory(double fullheight, double fullwidth) {
    bool prefReminder = Preference.shared.getBool(Preference.IS_REMINDER_ON) ?? false;
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 20, top: 50),
      child: Column(
        children: [
          Container(
            child: Row(
              children: [
                Container(
                  child: Image.asset(
                    'assets/icons/ic_clock_reminder.png',
                    scale: 3.5,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(),
                        child: Text(
                          (nextDrinkTime != null && prefReminder == true)
                              ? "${DateFormat.jm().format(nextDrinkTime!)}"
                              : Languages.of(context)!.txtTurnedOff,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colur.txt_white),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(),
                        child: Text(
                          Languages.of(context)!.txtNextTime,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colur.txt_grey),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text(
                    valueForIncrement.toString() +
                        " " +
                        Languages.of(context)!.txtMl,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colur.txt_grey),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _todayDrinkWaterHistory(
      double fullheight, double fullwidth, BuildContext context) {
    return ListView.builder(
      itemCount: drinkWaterHistory.length > 0 ? drinkWaterHistory.length : 0,
      padding: const EdgeInsets.only(bottom: 50),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return _itemDrinkWaterHistory(context, index);
      },
    );
  }

  _itemIconFromML(BuildContext context, int index) {
    if (drinkWaterHistory[index].ml == Constant.ML_100) {
      return 'assets/icons/water/ic_fill_100.png';
    } else if (drinkWaterHistory[index].ml == Constant.ML_150) {
      return 'assets/icons/water/ic_fill_150.png';
    } else if (drinkWaterHistory[index].ml == Constant.ML_250) {
      return 'assets/icons/water/ic_fill_250.png';
    } else if (drinkWaterHistory[index].ml == Constant.ML_500) {
      return 'assets/icons/water/ic_fill_500.png';
    }
  }

  _itemDrinkWaterHistory(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30.0,
            margin: const EdgeInsets.only(bottom: 10),
            child: VerticalDivider(
              color: Colur.txt_grey,
              thickness: 2.5,
            ),
          ),
          Container(
            child: Row(
              children: [
                Container(
                  width: 18.0,
                  height: 20.0,
                  child: Image.asset(
                    _itemIconFromML(context, index),
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 15,),
                Expanded(
                  child: Container(
                    child: Text(

                      "${drinkWaterHistory[index].time}",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colur.txt_white),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(),
                  child: Text(
                    "${drinkWaterHistory[index].ml}" +
                        " " +
                        Languages.of(context)!.txtMl,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colur.txt_grey),
                  ),
                ),
                PopupMenuButton(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onSelected: (value) {
                    if (value != null && value == 1) {
                      setState(() {
                        DataBaseHelper
                            .deleteTodayDrinkWater(drinkWaterHistory[index]);
                        _getDataFromDataBase();
                      });
                    }
                  },
                  itemBuilder: (context) {
                    return <PopupMenuItem>[
                      new PopupMenuItem(
                        height: 0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 7.0),
                          child: Text(
                            Languages.of(context)!.txtDelete,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colur.txt_black),
                          ),
                        ),
                        value: 1,
                      ),
                    ];
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Image.asset(
                      "assets/icons/ic_more.webp",
                      scale: 3.5,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
    if (name == Constant.STR_BACK) {
      Navigator.pop(context);
    }
    if (name == Constant.STR_SETTING_CIRCLE) {
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DrinkWaterSettingsScreen()))
          .then((value) {
            _getDataFromDataBase();
            _getPreference();
      });
    }
  }
}
