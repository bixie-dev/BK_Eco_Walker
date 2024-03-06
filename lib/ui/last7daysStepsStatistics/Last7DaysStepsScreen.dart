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


class Last7DaysStepsScreen extends StatefulWidget {
  @override
  _Last7DaysStepsScreenState createState() => _Last7DaysStepsScreenState();
}

class _Last7DaysStepsScreenState extends State<Last7DaysStepsScreen> implements TopBarClickListener{

  DateTime currentDate = DateTime.now();
  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  int touchedIndexForStepsChart = -1 ;

  List<StepsData>? stepsData;
  List dates = [];
  Map<String, int>? map = {};

  int? total = 0;
  double? avg = 0.0;

  @override
  void initState() {
    getLast7DaysData();
    getTotalLast7DaysSteps();
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
            SafeArea(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      child: CommonTopBar(
                        Languages.of(context)!.txtLast7daysReport,
                        this,
                        isShowBack: true,
                      ),
                    ),
                    reportWidget(fullHeight, fullWidth, context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  reportWidget(double fullHeight, double fullWidth, BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: fullHeight * 0.08),
        child: Column(
          children: [
            totalAndAverage(),
            buildStatisticsContainer(fullHeight, fullWidth, context)
          ],
        ),
      ),
    );
  }

  buildStatisticsContainer(double fullHeight, double fullWidth, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: fullHeight * 0.07),
      child: Column(
        children: [
          Text(
            DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[0])) + " - "+ DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[6])),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colur.txt_grey),
          ),
          graphWidgetWeek(fullHeight, fullWidth, context)
        ],
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
            right: fullWidth * 0.03
        ),
        height: fullHeight * 0.5,
        width: MediaQuery.of(context).size.width * 3,
        child: BarChart(
          BarChartData(
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colur.txt_grey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String day;
                      switch(group.x.toInt()) {
                        case 0:
                          day = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[0]));
                          break;
                        case 1:
                          day = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[1]));
                          break;
                        case 2:
                          day = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[2]));
                          break;
                        case 3:
                          day = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[3]));
                          break;
                        case 4:
                          day = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[4]));
                          break;
                        case 5:
                          day = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[5]));
                          break;
                        case 6:
                          day = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[6]));
                          break;
                        default:
                          throw Error();

                      }
                      return BarTooltipItem(
                        day + '\n',
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
                    touchedIndexForStepsChart = barTouchResponse.spot!.touchedBarGroupIndex;
                  });
                },
              ),
              gridData: FlGridData(
                show: false,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(sideTitles: xAxisTitleData(),),
                leftTitles: AxisTitles(sideTitles: yAxisTitleData(),),
                rightTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: false
                ),),
                topTitles:  AxisTitles(sideTitles: SideTitles(
                    showTitles: false
                ),),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border(
                      left: BorderSide.none,
                      top: BorderSide.none,
                      right: BorderSide.none,
                      bottom: BorderSide(
                          width: 1,
                          color: Colur.gray_border)
                  )
              ),
              barGroups: showingStepsGroups()
          ),
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
        var text;
        switch(value.toInt()) {
          case 0:
            text = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[0]));
            break;
          case 1:
            text = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[1]));
            break;
          case 2:
            text = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[2]));
            break;
          case 3:
            text = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[3]));
            break;
          case 4:
            text = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[4]));
            break;
          case 5:
            text = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[5]));
            break;
          case 6:
            text = DateFormat.MMMd(getLocale().languageCode).format(DateTime.parse(dates[6]));
            break;
          default:
            text = '';
        }

        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(text, style: _unSelectedTextStyle()),
        );
      },
    );
  }

  yAxisTitleData() {
    return SideTitles(
        showTitles: true,reservedSize: 35,
        getTitlesWidget: (value, TitleMeta meta) {
          return SideTitleWidget(child: Text(meta.formattedValue, style: TextStyle(
            color: Colur.txt_grey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),), axisSide: meta.axisSide);
        },
        interval: 5000
    );
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
                total.toString(),
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
                avg!.toStringAsFixed(2),
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

  _unSelectedTextStyle() {
    return const TextStyle(
        color: Colur.txt_grey, fontWeight: FontWeight.w400, fontSize: 14);
  }

  List<BarChartGroupData> showingStepsGroups() {
    List<BarChartGroupData> list = [];

    if (map!.isNotEmpty) {
      for (int i = 0; i < map!.length; i++) {
        list.add(makeBarChartGroupData(i, map!.entries.toList()[i].value.toDouble()));
      }
    } else {
      for (int i = 0; i < 7; i++) {
        list.add(makeBarChartGroupData(i, 0));
      }
    }
    return list;

  }

  makeBarChartGroupData(int index, double steps) {
    return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: steps+1,
            gradient: LinearGradient(colors: [Colur.green_gradient_color1, Colur.green_gradient_color2],),
            width: 45,
            borderRadius: BorderRadius.all(Radius.zero),
            backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 10000,
                gradient: LinearGradient(colors: [Colur.common_bg_dark,Colur.common_bg_dark],)
            ),
          ),
        ]
    );
  }

  getLast7DaysData() async {
    var startDate = getDate(currentDate.subtract(Duration(days: 8)));

    for(int i=0; i<7; i++) {
       var date = startDate.add(Duration(days: 1));
       dates.add(date.toString());
       startDate = date;
    }

    stepsData = await DataBaseHelper().getLast7DaysStepsData();

    for(int i=0; i<dates.length; i++) {
      bool isMatch = false;
      stepsData!.forEach((element) {
        if(element.stepDate == dates[i]){
          isMatch = true;
          map!.putIfAbsent(element.stepDate!, () => element.steps!);
        }
      });
      if(!isMatch) {
        map!.putIfAbsent(dates[i], () => 0);
      }
    }
    setState(() {  });
  }

  getTotalLast7DaysSteps() async {
    total = await DataBaseHelper().getTotalStepsForLast7Days();
    avg = total!/7;
    setState(() {});
  }



  @override
  void onTopBarClick(String name, {bool value = true}) {
    if(name == Constant.STR_BACK) {
      Navigator.pop(context);
    }
  }
}
