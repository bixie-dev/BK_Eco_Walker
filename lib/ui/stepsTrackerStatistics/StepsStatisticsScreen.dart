import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:run_tracker/common/commonTopBar/CommonTopBar.dart';
import 'package:run_tracker/dbhelper/DataBaseHelper.dart';
import 'package:run_tracker/dbhelper/datamodel/StepsData.dart';
import 'package:run_tracker/interfaces/TopBarClickListener.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/localization/locale_constant.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:intl/intl.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';

class StepsStatisticsScreen extends StatefulWidget {
  final int? currentStepCount;

  StepsStatisticsScreen({this.currentStepCount});

  @override
  _StepsTrackerStatisticsScreenState createState() =>
      _StepsTrackerStatisticsScreenState();
}

class _StepsTrackerStatisticsScreenState extends State<StepsStatisticsScreen>
    implements TopBarClickListener {
  DateTime currentDate = DateTime.now();
  var currentMonth = DateFormat('MM').format(DateTime.now());
  var currentYear = DateFormat.y().format(DateTime.now());

  int? daysInMonth;
  List<StepsData>? stepsDataMonth;
  Map<String, int> mapMonth = {};

  int? totalStepsMonth = 0;
  double? avgStepsMonth = 0.0;

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  List<StepsData>? stepsDataWeek;

  int? totalStepsWeek = 0;
  double? avgStepsWeek = 0.0;

  var currentDay =
      DateFormat('EEEE', getLocale().languageCode).format(DateTime.now());

  int touchedIndexForStepsChart = -1;

  List<String> weekDates = [];
  Map<String, int> mapWeek = {};

  bool isMonthSelected = false;
  bool isWeekSelected = true;

  List<String> allDays = DateFormat.EEEE(getLocale().languageCode)
      .dateSymbols
      .STANDALONESHORTWEEKDAYS;
  List<String> allMonths =
      DateFormat.EEEE(getLocale().languageCode).dateSymbols.MONTHS;

  int? prefSelectedDay;

  @override
  void initState() {
    prefSelectedDay =
        Preference.shared.getInt(Preference.FIRST_DAY_OF_WEEK_IN_NUM) ?? 1;
    daysInMonth =
        Utils.daysInMonth(int.parse(currentMonth), int.parse(currentYear));
    getChartDataOfStepsForMonth();
    getTotalStepsMonth();

    getChartDataOfStepsForWeek();
    getTotalStepsWeek();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var fullHeight = MediaQuery.of(context).size.height;
    var fullWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colur.common_bg_dark,
      resizeToAvoidBottomInset: true,
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SafeArea(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        child: CommonTopBar(
                          Languages.of(context)!.txtReport,
                          this,
                          isShowBack: true,
                        ),
                      ),
                      reportWidget(fullHeight, fullWidth, context),
                    ],
                  ),
                ),
              ),
            ),
            selectMonthOrWeek(fullHeight, fullWidth)
          ],
        ),
      ),
    );
  }

  selectMonthOrWeek(double fullHeight, double fullWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: fullHeight * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isMonthSelected = false;
                isWeekSelected = true;
              });
            },
            child: Container(
              height: fullHeight * 0.08,
              width: fullWidth * 0.3,
              decoration: isWeekSelected
                  ? BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colur.green_gradient_color1,
                        Colur.green_gradient_color2
                      ]),
                      borderRadius: BorderRadius.circular(50),
                    )
                  : BoxDecoration(
                      color: Colur.progress_background_color,
                      borderRadius: BorderRadius.circular(50),
                    ),
              child: Center(
                child: Text(
                  Languages.of(context)!.txtWeek,
                  style: TextStyle(
                      color: Colur.txt_white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                isMonthSelected = true;
                isWeekSelected = false;
              });
            },
            child: Container(
              height: fullHeight * 0.08,
              width: fullWidth * 0.3,
              decoration: isMonthSelected
                  ? BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colur.green_gradient_color1,
                        Colur.green_gradient_color2
                      ]),
                      borderRadius: BorderRadius.circular(50),
                    )
                  : BoxDecoration(
                      color: Colur.progress_background_color,
                      borderRadius: BorderRadius.circular(50),
                    ),
              child: Center(
                child: Text(
                  Languages.of(context)!.txtMonth,
                  style: TextStyle(
                      color: Colur.txt_white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  reportWidget(double fullHeight, double fullWidth, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: fullHeight * 0.015),
      child: Column(
        children: [
          totalAndAverage(),
          buildStatisticsContainer(fullHeight, fullWidth, context)
        ],
      ),
    );
  }

  buildStatisticsContainer(
      double fullHeight, double fullWidth, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: fullHeight * 0.055),
      child: Column(
        children: [
          Text(
            isMonthSelected
                ? displayMonth()
                : Languages.of(context)!.txtThisWeek,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colur.txt_grey),
          ),
          isMonthSelected
              ? graphWidgetMonth(fullHeight, fullWidth, context)
              : graphWidgetWeek(fullHeight, fullWidth, context)
        ],
      ),
    );
  }

  graphWidgetMonth(double fullHeight, double fullWidth, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: fullHeight * 0.05),
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: EdgeInsets.only(
              top: fullHeight * 0.01,
              left: fullWidth * 0.03,
              right: fullWidth * 0.03),
          height: fullHeight * 0.5,
          width: MediaQuery.of(context).size.width * 3,
          child: BarChart(
            BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colur.txt_grey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        int day = group.x + 1;
                        return BarTooltipItem(
                          "${day.toString()} ${displayMonth()}" + '\n',
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
                        touchedIndexForStepsChart = -1;
                        return;
                      }
                      touchedIndexForStepsChart =
                          barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
                  bottomTitles: AxisTitles(sideTitles: xAxisTitleData(),),
                  leftTitles: AxisTitles(sideTitles: yAxisTitleData(),),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
                ),
                borderData: FlBorderData(
                    show: true,
                    border: Border(
                        left: BorderSide.none,
                        right: BorderSide.none,
                        bottom:
                        BorderSide(width: 1, color: Colur.gray_border))),
                barGroups: showingStepsGroups()),
            swapAnimationCurve: Curves.ease,
            swapAnimationDuration: Duration(seconds: 0),
          ),
        ),
      ),
    );
  }

  graphWidgetWeek(double fullHeight, double fullWidth, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: fullHeight * 0.05,
      ),
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.only(
            top: fullHeight * 0.01,
            left: fullWidth * 0.03,
            right: fullWidth * 0.03),
        height: fullHeight * 0.5,
        width: MediaQuery.of(context).size.width * 3,
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
                      touchedIndexForStepsChart = -1;
                      return;
                    }
                    touchedIndexForStepsChart =
                        barTouchResponse.spot!.touchedBarGroupIndex;
                  });
                },
              ),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
                bottomTitles: AxisTitles(sideTitles: xAxisTitleData(),),
                leftTitles: AxisTitles(sideTitles: yAxisTitleData(),),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border(
                      left: BorderSide.none,
                      top: BorderSide.none,
                      right: BorderSide.none,
                      bottom: BorderSide(width: 1, color: Colur.gray_border))),
              barGroups: showingStepsGroups()),
          swapAnimationCurve: Curves.ease,
          swapAnimationDuration: Duration(seconds: 0),
        ),
      ),
    );
  }

  xAxisTitleData() {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        var style, text;
        if(isMonthSelected) {
          style = _unSelectedTextStyle();
          switch (value.toInt()) {
            case 0:
              text =  '1';
              break;
            case 1:
              text =  '2';
              break;
            case 2:
              text =  '3';
              break;
            case 3:
              text =  '4';
              break;
            case 4:
              text =  '5';
              break;
            case 5:
              text =  '6';
              break;
            case 6:
              text =  '7';
              break;
            case 7:
              text =  '8';
              break;
            case 8:
              text =  '9';
              break;
            case 9:
              text =  '10';
              break;
            case 10:
              text =  '11';
              break;
            case 11:
              text =  '12';
              break;
            case 12:
              text =  '13';
              break;
            case 13:
              text =  '14';
              break;
            case 14:
              text =  '15';
              break;
            case 15:
              text =  '16';
              break;
            case 16:
              text =  '17';
              break;
            case 17:
              text =  '18';
              break;
            case 18:
              text =  '19';
              break;
            case 19:
              text =  '20';
              break;
            case 20:
              text =  '21';
              break;
            case 21:
              text =  '22';
              break;
            case 22:
              text =  '23';
              break;
            case 23:
              text =  '24';
              break;
            case 24:
              text =  '25';
              break;
            case 25:
              text =  '26';
              break;
            case 26:
              text =  '27';
              break;
            case 27:
              text =  '28';
              break;
            case 28:
              text =  '29';
              break;
            case 29:
              text =  '30';
              break;
            case 30:
              text =  '31';
              break;
            default:
              text =  '';
          }
        } else {
          if (allDays.isNotEmpty) {
            Debug.printLog("value ===> $value");
            if (allDays[value.toInt()] == currentDay) {
              style = _selectedTextStyle();
              text = Languages.of(context)!.txtToday;
            } else {
              style = _unSelectedTextStyle();
              text = allDays[value.toInt()].substring(0, 3);
            }
          } else {
            style = _unSelectedTextStyle();
            text = "";
          }
        }
        return  SideTitleWidget(child: Text(text ?? "", style: style ?? _unSelectedTextStyle(),), axisSide: meta.axisSide);
      },
    );
  }

  yAxisTitleData() {
    return SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: (value, meta) {
          return SideTitleWidget(child: Text(meta.formattedValue, style: TextStyle(
            color: Colur.txt_grey,
            fontWeight: FontWeight.w500,
            fontSize: 12.4,
          ),), axisSide: meta.axisSide);
        },
        interval: 5000);
  }

  displayMonth() {
    switch (currentMonth) {
      case "01":
        return allMonths[0];
      case "02":
        return allMonths[1];
      case "03":
        return allMonths[2];
      case "04":
        return allMonths[3];
      case "05":
        return allMonths[4];
      case "06":
        return allMonths[5];
      case "07":
        return allMonths[6];
      case "08":
        return allMonths[7];
      case "09":
        return allMonths[8];
      case "10":
        return allMonths[9];
      case "11":
        return allMonths[10];
      case "12":
        return allMonths[11];
    }
  }

  totalAndAverage() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                Languages.of(context)!.txtTotal,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colur.txt_grey),
              ),
              Text(
                isMonthSelected
                    ? totalStepsMonth!.toString()
                    : totalStepsWeek!.toString(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colur.txt_white),
              )
            ],
          ),
          Column(
            children: [
              Text(
                Languages.of(context)!.txtAverage,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colur.txt_grey),
              ),
              Text(
                isMonthSelected
                    ? avgStepsMonth!.toStringAsFixed(2)
                    : avgStepsWeek!.toStringAsFixed(2),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colur.txt_white),
              )
            ],
          )
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

  List<BarChartGroupData> showingStepsGroups() {
    List<BarChartGroupData> list = [];

    if (isWeekSelected) {
      if (mapWeek.isNotEmpty) {
        for (int i = 0; i < mapWeek.length; i++) {
          list.add(makeBarChartGroupData(
              i, mapWeek.entries.toList()[i].value.toDouble()));
        }
      } else {
        for (int i = 0; i < 7; i++) {
          list.add(makeBarChartGroupData(i, 0));
        }
      }
    } else {
      if (mapMonth.isNotEmpty) {
        for (int i = 0; i < mapMonth.length; i++) {
          list.add(makeBarChartGroupData(
              i, mapMonth.entries.toList()[i].value.toDouble()));
        }
      } else {
        for (int i = 0; i < daysInMonth!; i++) {
          list.add(makeBarChartGroupData(i, 0));
        }
      }
    }
    return list;
  }

  makeBarChartGroupData(int index, double steps) {
    return BarChartGroupData(x: index, barRods: [
      BarChartRodData(
        toY: steps + 1,
        gradient: LinearGradient(colors: [Colur.green_gradient_color1, Colur.green_gradient_color2],),
        width: 45,
        borderRadius: BorderRadius.all(Radius.zero),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: 10000,
          gradient: LinearGradient(colors: [Colur.common_bg_dark,Colur.common_bg_dark],),
        ),
      ),
    ]);
  }

  getChartDataOfStepsForMonth() async {
    List<String>? monthDates = [];
    var startDateofMonth = DateTime(currentDate.year, currentDate.month, 1);

    for (int i = 0; i <= daysInMonth!; i++) {
      monthDates.add(startDateofMonth.toString());
      var date = startDateofMonth.add(Duration(days: 1));
      startDateofMonth = date;
    }
    stepsDataMonth = await DataBaseHelper().getStepsForCurrentMonth();

    for (int i = 0; i <= monthDates.length - 1; i++) {
      bool isMatch = false;
      stepsDataMonth!.forEach((element) {
        if (element.stepDate == monthDates[i]) {
          isMatch = true;
          mapMonth.putIfAbsent(element.stepDate!, () => element.steps!);
        }
      });
      if (monthDates[i] == getDate(currentDate).toString()) {
        isMatch = true;
        mapMonth.putIfAbsent(monthDates[i], () => widget.currentStepCount!);
      }
      if (!isMatch) {
        mapMonth.putIfAbsent(monthDates[i], () => 0);
      }
    }
    setState(() {});
  }

  getTotalStepsMonth() async {
    var s = await DataBaseHelper().getTotalStepsForCurrentMonth();
    totalStepsMonth = s! + widget.currentStepCount!;

    avgStepsMonth =
        (totalStepsMonth! + widget.currentStepCount!) / daysInMonth!;
  }

  getChartDataOfStepsForWeek() async {
    allDays = [];
    for (int i = 0; i <= 6; i++) {
      var currentWeekDates = getDate(DateTime.now()
          .subtract(Duration(days: currentDate.weekday - prefSelectedDay!))
          .add(Duration(days: i)));
      weekDates.add(currentWeekDates.toString());
      allDays.add(DateFormat('EEEE', getLocale().languageCode)
          .format(currentWeekDates));
    }
    stepsDataWeek = await DataBaseHelper().getStepsForCurrentWeek();
    for (int i = 0; i < weekDates.length; i++) {
      bool isMatch = false;
      stepsDataWeek!.forEach((element) {
        if (element.stepDate == weekDates[i]) {
          isMatch = true;
          mapWeek.putIfAbsent(element.stepDate!, () => element.steps!);
        }
      });
      if (weekDates[i] == getDate(currentDate).toString()) {
        isMatch = true;
        mapWeek.putIfAbsent(weekDates[i], () => widget.currentStepCount!);
      }
      if (!isMatch) {
        mapWeek.putIfAbsent(weekDates[i], () => 0);
      }
    }

    setState(() {});
  }

  getTotalStepsWeek() async {
    var s = await DataBaseHelper().getTotalStepsForCurrentWeek();
    totalStepsWeek = s! + widget.currentStepCount!;

    avgStepsWeek = (totalStepsWeek! + widget.currentStepCount!) / 7;
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
    if (name == Constant.STR_BACK) {
      Navigator.pop(context);
    }
  }
}
