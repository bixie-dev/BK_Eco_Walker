import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pedometer/pedometer.dart';
import 'package:run_tracker/ad_helper.dart';
import 'package:run_tracker/dbhelper/DataBaseHelper.dart';
import 'package:run_tracker/dbhelper/datamodel/StepsData.dart';
import 'package:run_tracker/localization/locale_constant.dart';
import 'package:run_tracker/ui/last7daysStepsStatistics/Last7DaysStepsScreen.dart';
import 'package:run_tracker/ui/stepsTracker/StepsPopUpMenu.dart';
import 'package:run_tracker/ui/stepsTrackerStatistics/StepsStatisticsScreen.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';

import '../../common/commonTopBar/CommonTopBar.dart';
import '../../interfaces/TopBarClickListener.dart';
import '../../localization/language/languages.dart';
import '../../utils/Constant.dart';

class StepsTrackerScreen extends StatefulWidget {
  @override
  _StepsTrackerScreenState createState() => _StepsTrackerScreenState();
}

class _StepsTrackerScreenState extends State<StepsTrackerScreen>
    implements TopBarClickListener {
  bool? isPause = true;


  int? targetSteps;
  TextEditingController targetStepController = TextEditingController();

  int? totalSteps = 0;
  int? currentStepCount;
  int? oldStepCount;

  double? distance;

  String? duration;
  int? time;
  int? oldTime;

  double? calories;
  int? height;
  int? weight;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  bool? isKmSelected;
  // ignore: cancel_subscriptions
  StreamSubscription<StepCount>? _stepCountStream;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  List<String> weekDates = [];

  int? last7DaysSteps;

  List<String> allDaysInSingleWord =
      DateFormat.EEEE(getLocale().languageCode).dateSymbols.NARROWWEEKDAYS;

  @override
  void initState() {
    getPreference();
    getisPauseFromPrefs();
    setTime();
    calculateDistance();
    DataBaseHelper().getAllStepsData();
    getStepsDataForCurrentWeek();
    getLast7DaysSteps();
    //_loadBanner();
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



  getisPauseFromPrefs() {
    isPause = Preference.shared.getBool(Preference.IS_PAUSE) ?? true;

    if (isPause == true) {
      if (currentStepCount! > 0) {
        currentStepCount = currentStepCount! - 1;
      }else {
        currentStepCount = 0;
      }
      // _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      _stopWatchTimer.onStartTimer();
      countStep();
    }
  }

  DateTime currentDate = DateTime.now();

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  List<StepsData>? stepsData;
  Map<String, int> map = {};

  List<double>? stepsPercentValue = [];

  @override
  Widget build(BuildContext context) {
    var fullHeight = MediaQuery.of(context).size.height;
    var fullWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colur.common_bg_dark,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Container(
                child: CommonTopBar(
                  Languages.of(context)!.txtStepsTracker,
                  this,
                  isShowBack: true,
                  isOptions: true,
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildStepIndiactorRow(context, fullHeight, fullWidth),

                      Container(
                        margin: EdgeInsets.only(top: fullHeight * 0.08),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildWeekCircularIndicator(
                                fullHeight,
                                allDaysInSingleWord[1],
                                stepsPercentValue!.isNotEmpty
                                    ? stepsPercentValue![0]
                                    : 0.0),
                            buildWeekCircularIndicator(
                                fullHeight,
                                allDaysInSingleWord[2],
                                stepsPercentValue!.isNotEmpty
                                    ? stepsPercentValue![1]
                                    : 0.0),
                            buildWeekCircularIndicator(
                                fullHeight,
                                allDaysInSingleWord[3],
                                stepsPercentValue!.isNotEmpty
                                    ? stepsPercentValue![2]
                                    : 0.0),
                            buildWeekCircularIndicator(
                                fullHeight,
                                allDaysInSingleWord[4],
                                stepsPercentValue!.isNotEmpty
                                    ? stepsPercentValue![3]
                                    : 0.0),
                            buildWeekCircularIndicator(
                                fullHeight,
                                allDaysInSingleWord[5],
                                stepsPercentValue!.isNotEmpty
                                    ? stepsPercentValue![4]
                                    : 0.0),
                            buildWeekCircularIndicator(
                                fullHeight,
                                allDaysInSingleWord[6],
                                stepsPercentValue!.isNotEmpty
                                    ? stepsPercentValue![5]
                                    : 0.0),
                            buildWeekCircularIndicator(
                                fullHeight,
                                allDaysInSingleWord[0],
                                stepsPercentValue!.isNotEmpty
                                    ? stepsPercentValue![6]
                                    : 0.0),
                          ],
                        ),
                      ),

                      otherInfo(fullHeight, context),

                      weeklyAverage(fullHeight, fullWidth, context),
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
        )
      ),
    );
  }

  weeklyAverage(double fullHeight, double fullWidth, BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Last7DaysStepsScreen()));
      },
      child: Container(
        margin: EdgeInsets.only(
            top: fullHeight * 0.1,
            right: fullWidth * 0.04,
            left: fullWidth * 0.04,
            bottom: fullHeight * 0.05),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colur.progress_background_color,
        ),
        padding: EdgeInsets.symmetric(
            vertical: fullWidth * 0.04, horizontal: fullWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Languages.of(context)!.txtLast7DaysSteps,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colur.txt_white),
            ),
            Container(
              margin: EdgeInsets.only(top: fullHeight * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    last7DaysSteps != null ? last7DaysSteps.toString() : "0",
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colur.txt_white),
                  ),
                  Visibility(
                    visible: true,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colur.common_bg_dark,
                          ),
                        ),
                        Image.asset(
                          "assets/icons/ic_arrow_green_gradient.png",
                          height: 12,
                          width: 7.41,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  otherInfo(double fullHeight, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: fullHeight * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              StreamBuilder<int>(
                  stream: _stopWatchTimer.rawTime,
                  builder: (context, snapshot) {
                    time = snapshot.hasData ? snapshot.data! + oldTime! : 0;
                    Preference.shared.setInt(Preference.OLD_TIME, time!);

                    duration = StopWatchTimer.getDisplayTime(
                      time!,
                      hours: true,
                      minute: true,
                      second: false,
                      milliSecond: false,
                      hoursRightBreak: "h ",
                    );
                    Preference.shared.setString(Preference.DURATION, duration!);
                    return Text(
                      duration! + "m",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: Colur.txt_white),
                    );
                  }),
              Text(
                Languages.of(context)!.txtDuration,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colur.txt_grey),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                calories!.toStringAsFixed(0),
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colur.txt_white),
              ),
              Text(
                Languages.of(context)!.txtKcal,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colur.txt_grey),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                distance!.toStringAsFixed(2),
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colur.txt_white),
              ),
              Text(
                isKmSelected! ? Languages.of(context)!.txtKM : Languages.of(context)!.txtMile,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colur.txt_grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildWeekCircularIndicator(double fullHeight, String weekDay, double value) {
    return Column(
      children: [
        CircularProgressIndicator(
          strokeWidth: 5,
          value: value,
          valueColor: AlwaysStoppedAnimation(Colur.txt_green),
          backgroundColor: Colur.progress_background_color,
        ),
        Container(
          margin: EdgeInsets.only(top: fullHeight * 0.02),
          child: Text(
            weekDay,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colur.txt_white),
          ),
        ),
      ],
    );
  }

  buildStepIndiactorRow(
      BuildContext context, double fullHeight, double fullWidth) {
    return Container(
      margin: EdgeInsets.only(
        left: fullWidth * 0.02,
        right: fullWidth * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isPause = !isPause!;
                Preference.shared.setBool(Preference.IS_PAUSE, isPause!);
              });

              Future.delayed(Duration(milliseconds: 100), () {
                if (isPause == true) {
                  if (currentStepCount! > 0) {
                    currentStepCount = currentStepCount! - 1;
                  }else {
                    currentStepCount = 0;
                  }
                  // _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                  _stopWatchTimer.onStartTimer();
                  countStep();
                } else {
                  // _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                  _stopWatchTimer.onStopTimer();
                  _stepCountStream!.cancel();
                }
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colur.progress_background_color,
                  ),
                ),
                Image.asset(
                  isPause == false
                      ? "assets/icons/ic_play.png"
                      : "assets/icons/ic_pause.png",
                  height: 14,
                  width: 12,
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: EdgeInsets.only(top: fullHeight * 0.02),
                width: fullWidth * 0.7,
                height: fullHeight * 0.3,
                child: stepsIndicator(),
              ),
              isPause!
                  ? Text(
                      Languages.of(context)!.txtSteps,
                      style: TextStyle(
                          color: Colur.txt_green,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    )
                  : Container(
                      padding: EdgeInsets.all(8),
                      height: 30,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colur.progress_background_color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          Languages.of(context)!.txtPaused,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.txt_white,
                              fontSize: 14,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    )
            ],
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StepsStatisticsScreen(
                          currentStepCount: currentStepCount!)));
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colur.progress_background_color,
                  ),
                ),
                Image.asset(
                  "assets/icons/ic_statistics.png",
                  height: 15,
                  width: 19,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  editTargetStepsBottomDialog(double fullHeight, double fullWidth) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colur.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: fullHeight * 0.5,
            color: Colur.common_bg_dark,
            child: Container(
              decoration: new BoxDecoration(
                  color: Colur.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32))),
              child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: fullHeight * 0.04, horizontal: fullWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Languages.of(context)!.txtEditTargetSteps,
                      style: TextStyle(
                          color: Colur.txt_black,
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                    ),

                    SizedBox(height: fullHeight * 0.01),

                    Text(
                      Languages.of(context)!.txtEditStepsTargetDesc,
                      style: TextStyle(
                          color: Colur.txt_grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),

                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: fullHeight * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Languages.of(context)!.txtSteps,
                              style: TextStyle(
                                  color: Colur.txt_black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600),
                            ),
                            Container(
                              height: 60,
                              width: 167,
                              decoration: BoxDecoration(
                                  color: Colur.txt_grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: TextFormField(
                                maxLines: 1,
                                maxLength: 7,
                                controller: targetStepController,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(
                                    color: Colur.txt_white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700),
                                cursorColor: Colur.txt_white,
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: InputBorder.none,
                                ),
                                onEditingComplete: () {
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: fullHeight * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 165,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colur.light_red_stop_gredient1,
                                Colur.light_red_gredient2
                              ]),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0.0, 25),
                                  spreadRadius: 2,
                                  blurRadius: 50,
                                  color: Colur.red_gradient_shadow,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colur.transparent,
                              child: InkWell(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    Navigator.pop(context);
                                  },
                                  child: Center(
                                    child: Text(
                                      Languages.of(context)!.txtCancel,
                                      style: TextStyle(
                                          color: Colur.txt_white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  )),
                            ),
                          ),

                          Container(
                            width: 165,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colur.green_gradient_color1,
                                Colur.green_gradient_color2
                              ]),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0.0, 25),
                                  spreadRadius: 2,
                                  blurRadius: 50,
                                  color: Colur.green_gradient_shadow,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colur.transparent,
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      targetSteps =
                                          int.parse(targetStepController.text);
                                    });
                                    if (targetSteps! > 50) {
                                      Preference.shared.setInt(
                                          Preference.TARGET_STEPS, targetSteps!);
                                      FocusScope.of(context).unfocus();
                                      Navigator.pop(context);
                                    } else {
                                      //TODO
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      Languages.of(context)!.txtSave,
                                      style: TextStyle(
                                          color: Colur.txt_white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  )),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      getStepsDataForCurrentWeek();
      FocusScope.of(context).unfocus();
    });
  }

  stepsIndicator() {
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(
          showTicks: false,
          showLabels: false,
          minimum: 0,
          maximum: targetSteps == null ? 6000 : targetSteps!.toDouble(),
          axisLineStyle: AxisLineStyle(
            thickness: 0.19,
            cornerStyle: CornerStyle.bothCurve,
            color: Colur.progress_background_color,
            thicknessUnit: GaugeSizeUnit.factor,
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value:
                  currentStepCount != null ? currentStepCount!.toDouble() : 0,
              gradient: SweepGradient(colors: [
                Colur.green_gradient_color1,
                Colur.green_gradient_color2
              ]),
              cornerStyle: CornerStyle.bothCurve,
              width: 0.19,
              sizeUnit: GaugeSizeUnit.factor,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                positionFactor: 0.1,
                angle: 90,
                widget: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentStepCount.toString(),
                        style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: Colur.txt_white),
                      ),
                      Text(
                        targetSteps == null ? "/6000" : "/$targetSteps",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colur.txt_grey),
                      ),
                    ],
                  ),
                ))
          ])
    ]);
  }

  countStep() {
    _stepCountStream = Pedometer.stepCountStream.listen((value) async {

      if (!mounted) {
        totalSteps = value.steps;
        Preference.shared.setInt(Preference.TOTAL_STEPS, totalSteps!);

        currentStepCount = currentStepCount! + 1;
        Preference.shared.setInt(Preference.CURRENT_STEPS, currentStepCount!);
      } else{
        setState(() {
          totalSteps = value.steps;
          Preference.shared.setInt(Preference.TOTAL_STEPS, totalSteps!);

          currentStepCount = currentStepCount! + 1;
          Preference.shared.setInt(Preference.CURRENT_STEPS, currentStepCount!);
        });
      }
      calculateDistance();
      calculateCalories();
      getTodayStepsPercent();
    }, onError: (error) {
      totalSteps = 0;
      Debug.printLog("Error: $error");
    }, cancelOnError: false);
  }

  getTodayStepsPercent() {
    var todayDate = getDate(DateTime.now()).toString();
    if (targetSteps == null) {
      targetSteps = 6000;
    }
    for (int i = 0; i < weekDates.length; i++) {
      if (todayDate == weekDates[i]) {
        if (!mounted){
          double value =
              currentStepCount!.toDouble() / targetSteps!.toDouble();
          if (value <= 1.0) {
            if (stepsPercentValue!.isNotEmpty) {
              stepsPercentValue![i] = value;
            }
          } else {
            stepsPercentValue![i] = 1.0;
          }
        }else{
          setState(() {
            double value =
                currentStepCount!.toDouble() / targetSteps!.toDouble();
            if (value <= 1.0) {
              if (stepsPercentValue!.isNotEmpty) {
                stepsPercentValue![i] = value;
              }
            } else {
              stepsPercentValue![i] = 1.0;
            }

          });
        }
      }
    }
  }

  openPopUpMenu(fullHeight, fullWidth) async {
    final String? result = await Navigator.push(context, StepsPopUpMenu());

    if (result == Constant.STR_EDIT_TARGET) {
      setState(() {
        var prefSteps = Preference.shared.getInt(Preference.TARGET_STEPS);

        if (prefSteps != null) {
          targetStepController.text = prefSteps.toString();
        } else {
          targetStepController.text = 6000.toString();
        }
        editTargetStepsBottomDialog(fullHeight, fullWidth);
      });
    }

    if (result == Constant.STR_RESET) {
      resetData();
    }

    if (result == Constant.STR_TURNOFF) {
      setState(() {
        if (isPause!) {
          // _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
          _stopWatchTimer.onStopTimer();
          _stepCountStream!.cancel();
          isPause = false;
          Preference.shared.setBool(Preference.IS_PAUSE, isPause!);
        }
      });
    }
  }

  getPreference() {
     targetSteps = Preference.shared.getInt(Preference.TARGET_STEPS) ?? 6000;
     currentStepCount = Preference.shared.getInt(Preference.CURRENT_STEPS) ?? 0;
     oldTime = Preference.shared.getInt(Preference.OLD_TIME) ?? 0;
     duration = Preference.shared.getString(Preference.DURATION) ?? "00h 0";
     distance = Preference.shared.getDouble(Preference.OLD_DISTANCE) ?? 0;
     calories = Preference.shared.getDouble(Preference.OLD_CALORIES) ?? 0;
     height = Preference.shared.getInt(Preference.HEIGHT) ?? 164;
     weight = Preference.shared.getInt(Preference.WEIGHT) ?? 50;
     isKmSelected = Preference.shared.getBool(Preference.IS_KM_SELECTED) ?? true;
  }

  resetData() {
    setState(() {
      totalSteps = Preference.shared.getInt(Preference.TOTAL_STEPS);
      oldStepCount = Preference.shared.getInt(Preference.TOTAL_STEPS);
      if (totalSteps != null) {
        currentStepCount = totalSteps! - oldStepCount!;
      } else {
        currentStepCount = 0;
      }
      Preference.shared.setInt(Preference.CURRENT_STEPS, currentStepCount!);

      distance = 0;
      Preference.shared.setDouble(Preference.OLD_DISTANCE, distance!);

      calories = 0;
      Preference.shared.setDouble(Preference.OLD_CALORIES, calories!);

      oldTime = 0;
      // _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      _stopWatchTimer.onResetTimer();
    });
    // if(isPause!) _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    if(isPause!) _stopWatchTimer.onStartTimer();

    var todayDate = getDate(DateTime.now()).toString();
    for (int i = 0; i < weekDates.length; i++) {
      if (todayDate == weekDates[i]) {
        setState(() {
          stepsPercentValue![i] = 0;
        });
      }
    }
  }

  calculateDistance() {
    if(!mounted) {
      if (isKmSelected!) {
        distance = currentStepCount! * 0.0008;
        Preference.shared.setDouble(Preference.OLD_DISTANCE, distance!);
      } else {
        distance = currentStepCount! * 0.0008 * 0.6214;
        Preference.shared.setDouble(Preference.OLD_DISTANCE, distance!);
      }
    } else {
      setState(() {
        if (isKmSelected!) {
          distance = currentStepCount! * 0.0008;
          Preference.shared.setDouble(Preference.OLD_DISTANCE, distance!);
        } else {
          distance = currentStepCount! * 0.0008 * 0.6214;
          Preference.shared.setDouble(Preference.OLD_DISTANCE, distance!);
        }
      });
    }
  }


  calculateCalories() {
    if(!mounted) {
      calories = currentStepCount! * 0.04;
      Preference.shared.setDouble(Preference.OLD_CALORIES, calories!);
    }else {
      setState(() {
        calories = currentStepCount! * 0.04;
        Preference.shared.setDouble(Preference.OLD_CALORIES, calories!);
      });
    }
  }

  setTime() {
    DateTime? oldDate;
    var date = Preference.shared.getString(Preference.DATE);
    if (date != null) {
      oldDate = DateTime.parse(date);
    }

    var currentDate = getDate(DateTime.now());
    Preference.shared.setString(Preference.DATE, currentDate.toString());

    if (oldDate != null) {
      if (currentDate != oldDate) {
        DataBaseHelper().insertSteps(StepsData(
            steps: currentStepCount,
            targetSteps: targetSteps != null ? targetSteps : 6000,
            cal: calories!.toInt(),
            distance: distance,
            duration: duration,
            time: Utils.getCurrentDayTime(),
            stepDate: oldDate.toString(),
            dateTime: Utils.getCurrentDateTime()));
        resetData();
      }
    }
  }

  getStepsDataForCurrentWeek() async {
    for (int i = 0; i <= 6; i++) {
      var currentWeekDates = getDate(DateTime.now()
          .subtract(Duration(days: currentDate.weekday - 1))
          .add(Duration(days: i)));
      weekDates.add(currentWeekDates.toString());
    }
    stepsData = await DataBaseHelper().getStepsForCurrentWeek();

    for (int i = 0; i < weekDates.length; i++) {
      bool isMatch = false;
      stepsData!.forEach((element) {
        if (element.stepDate == weekDates[i]) {
          isMatch = true;
          setState(() {
            double value = element.steps!.toDouble() / targetSteps!.toDouble();
            if (value <= 1.0) {
              stepsPercentValue!.add(value);
            } else {
              stepsPercentValue!.add(1.0);
            }
          });
        }
      });
      if (!isMatch) {
        setState(() {
          stepsPercentValue!.add(0.0);
        });
      }
    }
    getTodayStepsPercent();
  }

  getLast7DaysSteps() async {
    last7DaysSteps = await DataBaseHelper().getTotalStepsForLast7Days();
    setState(() {});
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
    if (name == Constant.STR_BACK) {
      Navigator.of(context).pop();
    }

    if (name == Constant.STR_OPTIONS) {
      openPopUpMenu(MediaQuery.of(context).size.height,
          MediaQuery.of(context).size.width);
    }
  }
}
