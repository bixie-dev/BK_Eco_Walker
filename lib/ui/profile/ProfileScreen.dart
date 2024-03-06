import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:run_tracker/custom/chart/CustomCircleSymbolRenderer.dart';
import 'package:run_tracker/custom/dialogs/AddWeightDialog.dart';
import 'package:run_tracker/dbhelper/DataBaseHelper.dart';
import 'package:run_tracker/dbhelper/datamodel/RunningData.dart';
import 'package:run_tracker/dbhelper/datamodel/WaterData.dart';
import 'package:run_tracker/dbhelper/datamodel/WeightData.dart';
import 'package:run_tracker/localization/locale_constant.dart';
import 'package:run_tracker/ui/recentActivities/RecentActivitiesScreen.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';

import '../../localization/language/languages.dart';
import '../../utils/Color.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int touchedIndexForWaterChart = -1;
  int touchedIndexForHartHealthChart = -1;

  var currentDate = DateTime.now();
  var currentDay;
  var startDateOfCurrentWeek;
  var endDateOfCurrentWeek;
  var formatStartDateOfCurrentWeek;
  var formatEndDateOfCurrentWeek;
  var startDateOfPreviousWeek;
  var endDateOfPreviousWeek;
  var formatStartDateOfPreviousWeek;
  var formatEndDateOfPreviousWeek;

  List<String> allDays = DateFormat.EEEE(getLocale().languageCode).dateSymbols.STANDALONESHORTWEEKDAYS;

  bool isNextWeek = false;
  bool isPreviousWeek = false;

  List<charts.Series<LinearSales, DateTime>>? series;
  List<LinearSales> data = [];

  int minWeight = Constant.MIN_KG.toInt();
  int maxWeight = Constant.MAX_KG.toInt();

  bool kmSelected = true;

  @override
  void initState() {
    _fillData();

    Debug.printLog(jsonEncode(allDays));

    isPreviousWeek = true;
    isNextWeek = false;

    int totalDaysInYear = DateTime(DateTime.now().year, 12, 31)
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    DateTime start = DateTime(DateTime.now().year, 1, 1);
    for (int i = 0; i < totalDaysInYear; i++) {
      data.add(LinearSales(start, null));
      start = start.add(Duration(days: 1));
    }
    super.initState();
  }

  _fillData() {
    _getPreference();
    _getDates();
    _getChartDataForDrinkWater();
    _getDailyDrinkWaterAverage();
    _getBestRecordsDataForDistance();
    _getBestRecordsDataForBestPace();
    _getBestRecordsDataForLongestDuration();
    _getLast30DaysWeightAverage();
    _getTotalDistanceForProgress();
    _getTotaCaloriesForProgress();
    _getAveragePaceForProgress();
    _getTotalHoursForProgress();
    _getChartDataForHeartHealth(isCurrent: true);
    _getChartDataForWeight();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  var prefTargetValue;
  int? prefSelectedDay;
  int? maxLimitOfDrinkWater;
  int? maxHeartHealth;
  int? prefMaxHeartHealth;

  _getPreference() {
    prefTargetValue =
        Preference.shared.getString(Preference.TARGET_DRINK_WATER);
    prefSelectedDay =
        Preference.shared.getInt(Preference.FIRST_DAY_OF_WEEK_IN_NUM) ?? 1;
    prefMaxHeartHealth =
        (Preference.shared.getInt(Preference.TARGETVALUE_FOR_WALKTIME) ?? 150) +
            (Preference.shared.getInt(Preference.TARGETVALUE_FOR_RUNTIME) ??
                75);
    setState(() {
      if (prefTargetValue == null) {
        maxLimitOfDrinkWater = 2000;
      } else {
        maxLimitOfDrinkWater = int.parse(prefTargetValue);
      }
      maxHeartHealth = prefMaxHeartHealth;
      kmSelected = Preference.shared.getBool(Preference.IS_KM_SELECTED) ?? true;
    });
  }

  List<RunningData>? totalRunningData;
  Map<String, int> mapRunning = {};

  _getChartDataForHeartHealth({bool isCurrent = false}) async {
    List<String> dates = [];
    allDays = [];
    for (int i = 0; i <= 6; i++) {
      var currentWeekDates = (isCurrent)
          ? getDate(DateTime.now()
              .subtract(Duration(days: currentDate.weekday - prefSelectedDay!))
              .add(Duration(days: i)))
          : getDate(DateTime.now()
              .subtract(
                  Duration(days: (currentDate.weekday - prefSelectedDay!) + 7))
              .add(Duration(days: i)));
      String formatCurrentWeekDates =
          DateFormat.yMMMd().format(currentWeekDates);

      allDays.add(DateFormat('EEEE',getLocale().languageCode).format(currentWeekDates));

      dates.add(formatCurrentWeekDates);
    }
    totalRunningData = await DataBaseHelper.getHeartHealth(dates);
    mapRunning.clear();
    for (int i = 0; i < dates.length; i++) {
      bool isMatch = false;
      totalRunningData!.forEach((element) {
        if (element.date == dates[i]) {
          if (element.allTotal != null)
            mapRunning.putIfAbsent(element.date!, () => (element.allTotal!));
          isMatch = true;
        }
      });
      if (!isMatch) mapRunning.putIfAbsent(dates[i], () => 0);
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

  RunningData? longestDistance;

  _getBestRecordsDataForDistance() async {
    longestDistance = await DataBaseHelper.getMaxDistance();
    Debug.printLog(
        "Longest Distance =====>" + longestDistance!.distance.toString());
    setState(() {});
    return longestDistance!;
  }

  RunningData? bestPace;

  _getBestRecordsDataForBestPace() async {
    bestPace = await DataBaseHelper.getMaxPace();
    Debug.printLog("Max Pace =====>" + bestPace!.speed.toString());
    setState(() {});
    return bestPace!;
  }

  RunningData? longestDuration;

  _getBestRecordsDataForLongestDuration() async {
    longestDuration = await DataBaseHelper.getLongestDuration();
    Debug.printLog(
        "Longest Duration =====>" + longestDuration!.duration.toString());
    setState(() {});
    return longestDuration!;
  }

  List<WeightData> weightDataList = [];

  _getChartDataForWeight() async {
    weightDataList = await DataBaseHelper.selectWeight();
    if (weightDataList.isNotEmpty) {
      minWeight = weightDataList[0].weightKg!.toInt();
      maxWeight = weightDataList[0].weightKg!.toInt();
    }

    weightDataList.forEach((element) {
      if (minWeight > element.weightKg!.toInt())
        minWeight = element.weightKg!.toInt();

      if (maxWeight < element.weightKg!.toInt())
        maxWeight = element.weightKg!.toInt();

      DateTime date = DateFormat.yMd().parse(element.date!);
      var index =
          data.indexWhere((element) => element.date.isAtSameMomentAs(date));
      if (index > 0) {
        data[index].sales = element.weightKg!.toInt();
      }
    });

    setState(() {});

    return weightDataList;
  }

  _getDates() {
    startDateOfCurrentWeek = getDate(currentDate
        .subtract(Duration(days: currentDate.weekday - prefSelectedDay!)));
    if (prefSelectedDay == 0) {
      endDateOfCurrentWeek =
          getDate(currentDate.add(Duration(days: DateTime.daysPerWeek - 4)));
    } else if (prefSelectedDay == 1) {
      endDateOfCurrentWeek = getDate(currentDate
          .add(Duration(days: DateTime.daysPerWeek - currentDate.weekday)));
    } else if (prefSelectedDay == -1) {
      endDateOfCurrentWeek =
          getDate(currentDate.add(Duration(days: DateTime.daysPerWeek - 5)));
    }
    formatStartDateOfCurrentWeek =
        DateFormat.MMMd(getLocale().languageCode).format(startDateOfCurrentWeek);
    formatEndDateOfCurrentWeek = DateFormat.MMMd(getLocale().languageCode).format(endDateOfCurrentWeek);

    startDateOfPreviousWeek = getDate(currentDate.subtract(
        Duration(days: (currentDate.weekday - prefSelectedDay!) + 7)));
    if (prefSelectedDay == 0) {
      endDateOfPreviousWeek = getDate(currentDate.add(
          Duration(days: (DateTime.daysPerWeek - currentDate.weekday) - 8)));
    } else if (prefSelectedDay == 1) {
      endDateOfPreviousWeek = getDate(currentDate.add(
          Duration(days: (DateTime.daysPerWeek - currentDate.weekday) - 7)));
    } else if (prefSelectedDay == -1) {
      endDateOfPreviousWeek = getDate(currentDate.add(
          Duration(days: (DateTime.daysPerWeek - currentDate.weekday) - 9)));
    }

    formatStartDateOfPreviousWeek =
        DateFormat.MMMd(getLocale().languageCode).format(startDateOfPreviousWeek);
    formatEndDateOfPreviousWeek =
        DateFormat.MMMd(getLocale().languageCode).format(endDateOfPreviousWeek);
  }

  String? weightAverage;

  _getLast30DaysWeightAverage() async {
    double? average = await DataBaseHelper.getLast30DaysWeightAverage();
    weightAverage =
        (average != null) ? average.toStringAsFixed(2) : 0.0.toString();
    setState(() {});
    Debug.printLog("weightAverage =====>" + weightAverage!);
  }

  RunningData? totalDistance;

  _getTotalDistanceForProgress() async {
    totalDistance = await DataBaseHelper.getSumOfTotalDistance();
    Debug.printLog("total distance: ${totalDistance!.total}");
    setState(() {});
  }

  RunningData? totalHours;

  _getTotalHoursForProgress() async {
    totalHours = await DataBaseHelper.getSumOfTotalDuration();
    Debug.printLog("total duration: ${totalHours!.duration}");

    setState(() {});
    return totalHours!;
  }

  RunningData? totalKcal;

  _getTotaCaloriesForProgress() async {
    totalKcal = await DataBaseHelper.getSumOfTotalCalories();
    Debug.printLog("total calories: ${totalKcal!.total}");
    setState(() {});
    return totalKcal!.total;
  }

  RunningData? avgPace;

  _getAveragePaceForProgress() async {
    avgPace = await DataBaseHelper.getAverageOfSpeed();
    Debug.printLog("average pace: ${avgPace!.total}");
    setState(() {});
    return avgPace!.total;
  }

  @override
  Widget build(BuildContext context) {
    currentDay = DateFormat('EEEE',getLocale().languageCode).format(DateTime.now());
    return Scaffold(
      backgroundColor: Colur.common_bg_dark,
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _runTrackerWidget(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _progressWidget(context),
                    _heartHealthWidget(context),
                    _weightWidget(context),
                    _drinkWaterWidget(context),
                    _bestRecordWidget(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _runTrackerWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colur.rounded_rectangle_color,
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: Container(
                              child: Text(
                                Languages.of(context)!.txtRunTracker,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colur.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 25),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          Languages.of(context)!.txtGoFasterSmarter,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.txt_grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/profileSettingScreen')
                        .then((value) => _fillData());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colur.gray_border,
                        width: 1,
                      ),
                    ),
                    child: Image.asset(
                      "assets/icons/ic_setting_round.png",
                      scale: 4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _progressWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
      margin: const EdgeInsets.only(top: 8.0),
      width: double.infinity,
      color: Colur.rounded_rectangle_color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Languages.of(context)!.txtMyProgress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colur.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecentActivitiesScreen())),
                child: Text(
                  Languages.of(context)!.txtMore.toUpperCase(),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colur.txt_purple,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 15.0),
            child: AutoSizeText(
              (totalDistance != null && totalDistance!.total != null)
                  ? (kmSelected)
                      ? totalDistance!.total!.toStringAsFixed(2)
                      : Utils.kmToMile(totalDistance!.total!).toStringAsFixed(2)
                  : "0.00",
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colur.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 50.0),
            ),
          ),
          Text(
            (kmSelected)
                ? Languages.of(context)!.txtTotalKM.toUpperCase()
                : Languages.of(context)!
                    .txtTotalMile
                    .toUpperCase()
                    .toUpperCase(),
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colur.white, fontWeight: FontWeight.w500, fontSize: 14),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 15.0),
                        child: AutoSizeText(
                          (totalHours != null && totalHours!.duration! != 0)
                              ? Utils.secToHour(totalHours!.duration!)
                                  .toStringAsFixed(2)
                              : "0.00",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 40.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Text(
                          Languages.of(context)!.txtTotalHours.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.txt_grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      child: AutoSizeText(
                        (totalKcal != null && totalKcal!.total! != 0)
                            ? totalKcal!.total!.toStringAsFixed(1)
                            : "0.0",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colur.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 40.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        Languages.of(context)!.txtTotalKCAL.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colur.txt_grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          (avgPace != null && avgPace!.total != null)
                              ? (kmSelected)
                                  ? avgPace!.total!.toStringAsFixed(2)
                                  : Utils.minPerKmToMinPerMile(avgPace!.total!)
                                      .toStringAsFixed(2)
                              : "0.00",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 40.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Text(
                          Languages.of(context)!.txtAvgPace.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.txt_grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _heartHealthWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
      margin: const EdgeInsets.only(top: 8.0),
      width: double.infinity,
      color: Colur.rounded_rectangle_color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Languages.of(context)!.txtHeartHealth,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colur.white, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isPreviousWeek)
                  InkWell(
                    onTap: () {
                      setState(() {
                        isPreviousWeek = false;
                        isNextWeek = true;
                      });
                      _getChartDataForHeartHealth(isCurrent: false);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(right: 25.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 16.0,
                        color: Colur.txt_purple,
                      ),
                    ),
                  ),
                Text(
                  (!isPreviousWeek && isNextWeek)
                      ? formatStartDateOfPreviousWeek.toString() +
                      " - " +
                      formatEndDateOfPreviousWeek.toString()
                      : formatStartDateOfCurrentWeek.toString() +
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
                if (isNextWeek)
                  InkWell(
                    onTap: () {
                      setState(() {
                        isPreviousWeek = true;
                        isNextWeek = false;
                      });
                      _getChartDataForHeartHealth(isCurrent: true);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16.0,
                        color: Colur.txt_purple,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 220,
            margin: EdgeInsets.only(top: 30.0),
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
                        touchedIndexForHartHealthChart = -1;
                        return;
                      }
                      touchedIndexForHartHealthChart =
                          barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          var style, text;
                          if (allDays.isNotEmpty) {
                            if (allDays[value.toInt()] == currentDay) {
                              style = _selectedTextStyle();
                            } else {
                              style = _unSelectedTextStyle();
                            }
                          } else {
                            style = _unSelectedTextStyle();
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
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      // margin: 5,
                      interval: 100,reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(child: Text(meta.formattedValue, style: TextStyle(
                            color: Colur.txt_grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 13),), axisSide: meta.axisSide);
                      },
                    ),)
                ),
                borderData: FlBorderData(
                    show: true,
                    border: Border(
                        top: BorderSide.none,
                        right: BorderSide.none,
                        bottom:
                        BorderSide(width: 1, color: Colur.gray_border))),
                barGroups: showingHeartHealthGroups(),
              ),
              swapAnimationCurve: Curves.ease,
              swapAnimationDuration: Duration(seconds: 0),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20.0),
            child: Text(
              Languages.of(context)!.txtWeek,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colur.txt_white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeHeartHealthGroupData(
      int x,
      double y, {
        bool isTouched = false,
        Color barColor = Colur.graph_health,
        double width = 32,
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          gradient: LinearGradient(colors: isTouched ? [Colur.white,Colur.white] : [barColor,barColor],),
          width: width,
          borderRadius: BorderRadius.all(Radius.zero),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxHeartHealth!.toDouble(),
            gradient: LinearGradient(colors: [Colur.common_bg_dark,Colur.common_bg_dark],),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> showingHeartHealthGroups() {
    List<BarChartGroupData> list = [];

    for (int i = 0; i < mapRunning.length; i++) {
      list.add(makeHeartHealthGroupData(
          i,  Utils.secToMin(mapRunning.entries.toList()[i].value).toDouble(),
          isTouched: i == touchedIndexForHartHealthChart));
    }

    return list;
  }

  _selectedTextStyle() {
    return const TextStyle(
        color: Colur.txt_white, fontWeight: FontWeight.w400, fontSize: 14);
  }

  _unSelectedTextStyle() {
    return const TextStyle(
        color: Colur.txt_grey, fontWeight: FontWeight.w400, fontSize: 14);
  }

  _weightWidget(BuildContext context) {
    series = [
      new charts.Series<LinearSales, DateTime>(
        id: 'Weight',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(Colur.purple_gradient_color1),
        domainFn: (LinearSales sales, _) => sales.date,
        measureFn: (LinearSales sales, _) => sales.sales,
        radiusPxFn: (LinearSales sales, _) => 5,
        data: data,
      )
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
      margin: const EdgeInsets.only(top: 8.0),
      width: double.infinity,
      color: Colur.rounded_rectangle_color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Languages.of(context)!.txtWeight,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colur.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                ),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AddWeightDialog()).then((value) {
                    _fillData();
                  });
                },
                child: Text(
                  Languages.of(context)!.txtAdd.toUpperCase(),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colur.txt_purple,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20.0),
            child: Text(
              (weightAverage != null)
                  ? weightAverage! + Languages.of(context)!.txtKG.toLowerCase()
                  : "0.0" + Languages.of(context)!.txtKG.toLowerCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colur.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 5.0),
            child: Text(
              Languages.of(context)!.txtLast30Days,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colur.txt_grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            width: double.infinity,
            height: 350,
            child: charts.TimeSeriesChart(
              series!,
              animate: false,
              domainAxis: new charts.DateTimeAxisSpec(
                tickProviderSpec: charts.DayTickProviderSpec(increments: [1]),
                viewport: new charts.DateTimeExtents(
                    start: DateTime.now().subtract(Duration(days: 5)),
                    end: DateTime.now().add(Duration(days: 3))),
                tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                    day: new charts.TimeFormatterSpec(
                        format: 'd', transitionFormat: 'dd/MM')),
                renderSpec: new charts.SmallTickRendererSpec(
                  labelStyle: new charts.TextStyleSpec(
                      fontSize: 15,
                      color: charts.ColorUtil.fromDartColor(Colur.txt_grey)),
                  lineStyle: new charts.LineStyleSpec(
                      color: charts.ColorUtil.fromDartColor(Colur.txt_grey)),
                ),
              ),
              behaviors: [
                new charts.PanBehavior(),
                charts.LinePointHighlighter(
                    symbolRenderer:
                        CustomCircleSymbolRenderer()
                    )
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                    zeroBound: false,
                    dataIsInWholeNumbers: true,
                    desiredTickCount: 5),
                renderSpec: charts.GridlineRendererSpec(
                  lineStyle: new charts.LineStyleSpec(
                      color: charts.ColorUtil.fromDartColor(Colur.txt_grey)),
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 12,
                    fontWeight: FontWeight.w500.toString(),
                    color: charts.ColorUtil.fromDartColor(Colur.txt_grey),
                  ),
                ),
              ),
              selectionModels: [
                charts.SelectionModelConfig(
                    changedListener: (charts.SelectionModel model) {
                  if (model.hasDatumSelection) {
                    final value = model.selectedSeries[0]
                        .measureFn(model.selectedDatum[0].index);
                    CustomCircleSymbolRenderer.value =
                        value.toString();
                  }
                })
              ],
            ),
          ),
        ],
      ),
    );
  }

  _drinkWaterWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
      margin: const EdgeInsets.only(top: 8.0),
      width: double.infinity,
      color: Colur.rounded_rectangle_color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Languages.of(context)!.txtDrinkWater,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colur.white, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20.0),
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
            height: 220,
            margin: EdgeInsets.only(top: 30.0),
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
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        var style, text;
                        if (allDays.isNotEmpty) {
                          if (allDays[value.toInt()] == currentDay) {
                            style = _selectedTextStyle();
                          } else {
                            style = _unSelectedTextStyle();
                          }
                        } else {
                          style = _unSelectedTextStyle();
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
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
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
            margin: EdgeInsets.only(top: 20.0),
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
                  color: Colur.txt_purple,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.5),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20.0),
            child: Text(
              Languages.of(context)!.txtWeek,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colur.txt_white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22),
            ),
          ),
        ],
      ),
    );
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
          gradient: LinearGradient(colors: isTouched ? [Colur.white,Colur.white] : [barColor,barColor],),
          width: width,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
              topLeft: Radius.circular(3.0),
              topRight: Radius.circular(3.0)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxLimitOfDrinkWater!.toDouble(),
            gradient: LinearGradient(colors: [Colur.common_bg_dark,Colur.common_bg_dark],),
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

  _bestRecordWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 25.0, left: 25.0, right: 25.0, bottom: 40.0),
      margin: const EdgeInsets.only(top: 8.0),
      width: double.infinity,
      color: Colur.rounded_rectangle_color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Languages.of(context)!.txtBestRecords,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colur.white, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colur.common_bg_dark,
                borderRadius: BorderRadius.circular(10.0)),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            margin: const EdgeInsets.only(top: 30.0),
            child: Row(
              children: [
                Image.asset(
                  "assets/icons/ic_distance_light.webp",
                  scale: 3.5,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Languages.of(context)!.txtLongestDistance.toUpperCase(),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                (longestDistance != null &&
                                        longestDistance!.date != null)
                                    ? (kmSelected)
                                        ? longestDistance!.distance!
                                            .toStringAsFixed(2)
                                        : Utils.kmToMile(
                                                longestDistance!.distance!)
                                            .toStringAsFixed(2)
                                    : "0.0",
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colur.txt_purple,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, bottom: 3.0),
                                  child: Text(
                                    (kmSelected)
                                        ? Languages.of(context)!
                                            .txtKM
                                            .toLowerCase()
                                        : Languages.of(context)!
                                            .txtMile
                                            .toLowerCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colur.txt_purple,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 5.0, bottom: 3.0),
                                child: Text(
                                  (longestDistance != null &&
                                          longestDistance!.date != null)
                                      ? longestDistance!.date!
                                      : "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colur.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colur.common_bg_dark,
                borderRadius: BorderRadius.circular(10.0)),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            margin: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                Image.asset(
                  "assets/icons/ic_best_pace_light.webp",
                  scale: 3.5,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Languages.of(context)!.txtBestPace.toUpperCase(),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                (bestPace != null && bestPace!.speed != null)
                                    ? (kmSelected)
                                        ? bestPace!.speed!.toStringAsFixed(2)
                                        : Utils.minPerKmToMinPerMile(
                                                bestPace!.speed!)
                                            .toStringAsFixed(2)
                                    : "0.0",
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colur.txt_purple,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 5.0, bottom: 3.0),
                                child: Text(
                                  (kmSelected)
                                      ? Languages.of(context)!
                                          .txtMinKm
                                          .toLowerCase()
                                      : Languages.of(context)!
                                          .txtMinMi
                                          .toLowerCase(),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colur.txt_purple,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colur.common_bg_dark,
                borderRadius: BorderRadius.circular(10.0)),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Row(
              children: [
                Image.asset(
                  "assets/icons/ic_duration_light.webp",
                  scale: 3.5,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Languages.of(context)!.txtLongestDuration.toUpperCase(),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  (longestDuration != null &&
                                          longestDuration!.duration != null)
                                      ? Utils.secToString(
                                          longestDuration!.duration!)
                                      : "00:00",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colur.txt_purple,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 22),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 5.0, bottom: 3.0),
                                child: Text(
                                  (longestDuration != null &&
                                          longestDuration!.duration != null)
                                      ? longestDuration!.date!
                                      : "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colur.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LinearSales {
  DateTime date;
  int? sales;

  LinearSales(this.date, this.sales);
}
