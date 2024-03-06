import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:run_tracker/custom/GradientButtonSmall.dart';
import 'package:run_tracker/custom/custom_tabbarview.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';

class WeeklyGoalSetScreen extends StatefulWidget {
  final String? gender;
  final int? height;
  final int? weight;

  WeeklyGoalSetScreen({
    Key? key,
    required this.gender,
    required this.height,
    required this.weight,
  }) : super(key: key);

  @override
  _WeeklyGoalSetScreenState createState() => _WeeklyGoalSetScreenState();


}

class _WeeklyGoalSetScreenState extends State<WeeklyGoalSetScreen> {
  bool kmSelected = true;
  bool mileSelected = false;

  bool unit = true;
  var distanceKM = 6;
  var distanceMILE = 6;


  @override
  void initState() {
    super.initState();
  }

  void onAutoPressed() {

    convert();
    Preference.shared.setBool(Preference.IS_USER_FIRSTTIME, false);

    setDataToPrefs();

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/homeWizardScreen', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {

    var fullHeight = MediaQuery.of(context).size.height;
    var fullWidth = MediaQuery.of(context).size.width;

    //onAutoPressed();

    return Scaffold(
      body: Container(
        height: fullHeight,
        width: fullWidth,
        color: Colur.common_bg_dark,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: fullHeight * 0.15),
              child: Text(
                Languages.of(context)!.txtYourWeeklyGoalIsReady,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colur.txt_white,
                    fontSize: 28),
              ),
            ),

            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: fullHeight * 0.07),
                child: CustomTabBar(
                    tab1: Languages.of(context)!.txtHeartHealth,
                    tab2: Languages.of(context)!.txtDistance,

                    forDistance: _forDistance(fullHeight),
                    forHeart: _forHeart(fullHeight, fullWidth)),

              ),
            ),


            _setAsMyGoalButton(fullHeight, fullWidth),
          ],
        ),
      ),
    );
  }

  Widget _forHeart(double fullHeight, double fullWidth) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: fullHeight * 0.06),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colur.light_yellow_gredient1,
                        Colur.light_yellow_gredient2,
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.all(Radius.circular(36))),
                  child: Container(
                      height: 1,
                      width: 1,
                      child: Image.asset("assets/icons/ic_walk.png",
                          scale: 3.8, color: Colur.white)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        Languages.of(context)!
                            .txt150MinBriskWalking
                            .toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colur.txt_white,
                            fontSize: 20),
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 5.0),
                        child: Text(
                          Languages.of(context)!.txtPaceBetween9001500MinKm,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colur.txt_grey,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                Languages.of(context)!.txtOR.toUpperCase(),
                style: TextStyle(
                    color: Colur.txt_grey,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colur.light_red_gredient1,
                        Colur.light_red_gredient2,
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.all(Radius.circular(36))),
                  child: Container(
                      height: 1,
                      width: 1,
                      child: Image.asset("assets/icons/ic_run.png",
                          scale: 3.8, color: Colur.white)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        Languages.of(context)!.txt75MinRunning.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colur.txt_white,
                            fontSize: 20),
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 5.0),
                        child: Text(
                          Languages.of(context)!.txtPaceOver900MinKm,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colur.txt_grey,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                    left: fullWidth * 0.06, top: fullHeight * 0.05),
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/ic_info.webp',
                      scale: 3.4,
                      color: Colur.txt_grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        Languages.of(context)!
                            .txtYouCanCombineTheseTwoDescription,
                        maxLines: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colur.txt_grey),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _forDistance(double fullHeight) {
    return Container(
      child: Column(
        children: [
          _distanceUnitTab(fullHeight),
          _curpentinoPickerDesign(fullHeight),
        ],
      ),
    );
  }

  _distanceUnitTab(double fullHeight) {
    return Container(
      margin: EdgeInsets.only(top: fullHeight * 0.03),
      height: 60,
      width: 205,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colur.txt_grey, width: 1.5),
        color: Colur.common_bg_dark,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                kmSelected = true;
                mileSelected = false;
                unit = true;
              });
            },
            child: Container(
              width: 100,
              child: Center(
                child: Text(
                  Languages.of(context)!.txtKM,
                  style: TextStyle(
                      color: kmSelected ? Colors.white : Colur.txt_grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
            ),
          ),
          Container(
            height: 23,
            child: VerticalDivider(
              color: Colur.txt_grey,
              width: 1,
              thickness: 1,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                kmSelected = false;
                mileSelected = true;
                unit = false;
              });
            },
            child: Container(
              width: 100,
              child: Center(
                child: Text(
                  Languages.of(context)!.txtMile,
                  style: TextStyle(
                      color: mileSelected ? Colur.white :Colur.txt_grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _setAsMyGoalButton( double fullHeight, double fullWidth) {
    return Container(
      margin: EdgeInsets.only(left: fullWidth*0.15, bottom: fullHeight*0.06, right: fullWidth*0.15),
      alignment: Alignment.bottomCenter,
      child: GradientButtonSmall(
        width: double.infinity,
        height: 60,
        radius: 50.0,
        child: Text(
          Languages.of(context)!.txtSetAsMyGoal.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colur.white, fontWeight: FontWeight.w500, fontSize: 18.0),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colur.purple_gradient_color1,
            Colur.purple_gradient_color2,
          ],
        ),
        onPressed: () {

          onAutoPressed();

        },
      ),
    );
  }

  _curpentinoPickerDesign(double fullHeight) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Image.asset(
                "assets/icons/ic_select_pointer.png",
              ),
            ),
          ),
          Container(
            width: 125,
            height: fullHeight * 0.32,
            child: CupertinoPicker(
              backgroundColor: Colur.common_bg_dark,
              useMagnifier: true,
              magnification: 1.05,
              looping: true,
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: Colur.transparent,),
              onSelectedItemChanged: (value) {
                setState(() {
                  if (unit == false) {
                    value += 1;
                    distanceMILE = value;
                  } else {
                    value += 1;
                    distanceKM = value;
                  }
                });
              },
              itemExtent: 75.0,
              children: unit == false
                  ? List.generate(2155, (index) {
                index += 1;
                return Text(
                  "$index",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold),
                );
              })
                  : List.generate(978, (index) {
                index += 1;
                return Text(
                  "$index",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold),
                );
              }),
            ),
          ),
          (kmSelected == true)
              ? Container(
            margin: EdgeInsets.only(left: 5),
            child: Text(
              Languages.of(context)!.txtKM,
              style: TextStyle(
                  color: Colur.txt_white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
          )
              : Container(
            margin: EdgeInsets.only(left: 5),
            child: Text(
              Languages.of(context)!.txtMile,
              style: TextStyle(
                  color: Colur.txt_white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }



  setDataToPrefs() {
    if(Debug.STORE_RES_IN_PREF) {

      Preference.shared.setString(Preference.GENDER, widget.gender!);

      Preference.shared.setInt(Preference.WEIGHT, widget.weight!);

      Preference.shared.setInt(Preference.HEIGHT, widget.height!);

      Preference.shared.setInt(Preference.DISTANCE, distanceKM);
    }
  }

  convert() {
    if(unit == false) {
      var d = distanceMILE*1.609;
      distanceKM = d.toInt();
    }
  }
}