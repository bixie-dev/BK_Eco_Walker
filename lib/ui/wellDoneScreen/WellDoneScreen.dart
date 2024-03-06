
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'as lottie;
import 'package:run_tracker/common/commonTopBar/CommonTopBar.dart';
import 'package:run_tracker/custom/bottomsheetdialogs/RatingDialog.dart';
import 'package:run_tracker/dbhelper/DataBaseHelper.dart';
import 'package:run_tracker/dbhelper/datamodel/RunningData.dart';
import 'package:run_tracker/interfaces/TopBarClickListener.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/ui/shareScreen/ShareScreen.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../custom/GradientButtonSmall.dart';

class WellDoneScreen extends StatefulWidget {
  final RunningData? runningData;
  WellDoneScreen({this.runningData});

  @override
  _WellDoneScreenState createState() => _WellDoneScreenState();
}

class _WellDoneScreenState extends State<WellDoneScreen>
    implements TopBarClickListener {

  bool kmSelected = true;
  TextEditingController _textFeedback = TextEditingController();

  @override
  void initState() {
    _getPreferences();
    saveDataAndExit();
    super.initState();

  }
  _getPreferences(){
    setState(() {
      kmSelected =
          Preference.shared.getBool(Preference.IS_KM_SELECTED) ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var fullheight = MediaQuery.of(context).size.height;
    var fullwidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/homeWizardScreen', (Route<dynamic> route) => false);
        return false;
      },
      child: Scaffold(
          backgroundColor: Colur.common_bg_dark,
          body: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        child: CommonTopBar(
                          "",
                          this,
                          isClose: true,
                          isDelete: true,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: fullheight * 0.12,bottom: 25),
                              child: Text(
                                Languages.of(context)!.txtWellDone.toUpperCase(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colur.txt_white,
                                    fontSize: 30),
                              ),
                            ),
                            _mapScreenShot(fullheight, fullwidth),
                            _informationViewOfDistance(fullheight, fullwidth),
                            _intensityViewOfWalking(fullheight,fullwidth),
                            _detailsAndShareButtonView(fullheight, fullwidth),
                            _satisfyListTile(fullheight, fullwidth),
                          ],
                        ),
                      ),
                    ],
                  ),


                  SafeArea(
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: lottie.Lottie.asset(
                        'assets/animation/thumbs_up.json',
                        width: 200,
                        height: 200,
                        repeat: true,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Container(
                      margin: EdgeInsets.only(top: 55),
                      child: lottie.Lottie.asset(
                          'assets/animation/congratulation.json',
                          repeat: true,
                          alignment: Alignment.topCenter
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  @override
  Future<void> onTopBarClick(String name, {bool value = true}) async {
    if (name == Constant.STR_DELETE) {
      _showDeleteDialog(context);
    }
    if (name == Constant.STR_CLOSE) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/homeWizardScreen', (Route<dynamic> route) => false);
    }
  }

  saveDataAndExit() async {
    var data = widget.runningData!;

    int id = await DataBaseHelper.insertRunningData(RunningData(id: null,
        duration: data.duration,
        distance: data.distance,
        speed: data.speed,
        cal: data.cal,
        sLat: data.sLat,
        sLong: data.sLong,
        eLat: data.eLat,
        eLong: data.eLong,
        image: data.image,
        polyLine: data.polyLine,
        lowIntenseTime: data.lowIntenseTime,
        moderateIntenseTime: data.moderateIntenseTime,
        highIntenseTime: data.highIntenseTime,
        date: data.date,
        total: null));

    widget.runningData!.id = id;

  }


  _showDeleteDialog(BuildContext context){
    return  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Languages.of(context)!.txtDeleteHitory),
          content: Text(Languages.of(context)!.txtDeleteConfirmationMessage,maxLines: 2,overflow: TextOverflow.ellipsis),
          actions: [
            TextButton(
              child: Text(Languages.of(context)!.txtCancel),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(Languages.of(context)!.txtDelete.toUpperCase()),
              onPressed: () async {
                await DataBaseHelper.deleteRunningData(widget.runningData!).then((value) => Navigator.of(context)
                    .pushNamedAndRemoveUntil('/homeWizardScreen', (Route<dynamic> route) => false));

              },
            ),

          ],
        );
      },
    );
  }

  _mapScreenShot(double fullheight, double fullwidth) {
    widget.runningData!.getPolyLineData();
    return Container(
      width: fullwidth,
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        child: (widget.runningData!.imageFile != null)?Image.file(
          widget.runningData!.imageFile!,fit: BoxFit.contain,): Image.asset(
          'assets/images/dummy_map.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  _informationViewOfDistance(double fullheight, double fullwidth) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 2, bottom: 7),
                    child: Text(
                      Languages.of(context)!.txtDuration,
                      style: TextStyle(
                          color: Colur.txt_grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                  Container(
                    child: Text(
                      Utils.secToString(widget.runningData!.duration!),
                      style: TextStyle(
                          color: Colur.txt_white,
                          fontWeight: FontWeight.w600,
                          fontSize: 35),
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 2, bottom: 7),
                    child: Text(
                      Languages.of(context)!.txtDistance+"("+Languages.of(context)!.txtKM.toUpperCase()+")",
                      style: TextStyle(
                          color: Colur.txt_grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                  Container(
                    child: Text(
                      widget.runningData!.distance.toString(),
                      style: TextStyle(
                          color: Colur.txt_white,
                          fontWeight: FontWeight.w600,
                          fontSize: 35),
                    ),
                  )
                ],
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 2, bottom: 7),
                      child: Text(
                        (kmSelected)?Languages.of(context)!.txtPaceMinPer+Languages.of(context)!.txtKM.toUpperCase()+")":Languages.of(context)!.txtPaceMinPer+Languages.of(context)!.txtMile.toUpperCase()+")",
                        style: TextStyle(
                            color: Colur.txt_grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                    Container(
                      child: Text(
                        (kmSelected)? widget.runningData!.speed!.toStringAsFixed(2):Utils.minPerKmToMinPerMile(widget.runningData!.speed!).toStringAsFixed(2),
                        style: TextStyle(
                            color: Colur.txt_white,
                            fontWeight: FontWeight.w600,
                            fontSize: 24),
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 2, bottom: 7),
                      child: Text(
                        Languages.of(context)!.txtKCAL,
                        style: TextStyle(
                            color: Colur.txt_grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                    Container(
                      child: Text(
                        widget.runningData!.cal.toString(),
                        style: TextStyle(
                            color: Colur.txt_white,
                            fontWeight: FontWeight.w600,
                            fontSize: 24),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _intensityViewOfWalking(double fullheight, double fullwidth) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom:8.0),
            child: Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  margin: EdgeInsets.only(right: 15),
                  child: Image.asset('assets/icons/low_intensity_icon.png',),
                ),
                Expanded(child: Text(Languages.of(context)!.txtLow.toUpperCase()+" "+Languages.of(context)!.txtIntensity.toUpperCase(),style: TextStyle(color: Colur.txt_white,fontSize: 18,fontWeight: FontWeight.w500),)),
                Container(
                  child: Text(Utils.secToString(widget.runningData!.lowIntenseTime!)+" "+Languages.of(context)!.txtMin,style: TextStyle(color: Colur.txt_white,fontSize: 18,fontWeight: FontWeight.w500),),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom:8.0),
            child: Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  margin: EdgeInsets.only(right: 15),
                  child: Image.asset('assets/icons/modrate_intensity_icon.png',),
                ),
                Expanded(child: Text(Languages.of(context)!.txtModerate.toUpperCase()+" "+Languages.of(context)!.txtIntensity.toUpperCase(),style: TextStyle(color: Colur.txt_white,fontSize: 18,fontWeight: FontWeight.w500),)),
                Container(
                  child: Text(Utils.secToString(widget.runningData!.moderateIntenseTime!)+" "+Languages.of(context)!.txtMin,style: TextStyle(color: Colur.txt_white,fontSize: 18,fontWeight: FontWeight.w500),),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom:8.0),
            child: Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  margin: EdgeInsets.only(right: 15),
                  child: Image.asset('assets/icons/high_intensity_icon.png',),
                ),
                Expanded(child: Text(Languages.of(context)!.txtHigh.toUpperCase()+" "+Languages.of(context)!.txtIntensity.toUpperCase(),style: TextStyle(color: Colur.txt_white,fontSize: 18,fontWeight: FontWeight.w500),)),
                Container(
                  child: Text(Utils.secToString(widget.runningData!.highIntenseTime!)+" "+Languages.of(context)!.txtMin,style: TextStyle(color: Colur.txt_white,fontSize: 18,fontWeight: FontWeight.w500),),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _detailsAndShareButtonView(double fullheight, double fullwidth) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ShareScreen(widget.runningData)));
      },
      child: Container(
        height: 60,
        width: fullwidth,
        margin: EdgeInsets.only(top: 30, bottom: 30,left: 20,right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colur.purple_gradient_color1,
              Colur.purple_gradient_color2,
            ],
          ),),
        child: Center(
          child: Text(
            Languages.of(context)!.txtShare,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colur.txt_white,
                fontWeight: FontWeight.w500,
                fontSize: 18.0),
          ),
        ),

      ),
    );
  }

  _satisfyListTile(double fullheight, double fullwidth) {
    return Container(
      color: Colur.transparent,
      child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colur.ligh_green_For_NotReally,
                borderRadius: BorderRadius.all(Radius.circular(13)),
              ),
              margin: EdgeInsets.only(top: 50.0),
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Text(
                      Languages.of(context)!.txtAreYouSatisfiedWithDescription,
                      maxLines: 2,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colur.txt_white),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 30,bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GradientButtonSmall(
                            width: 140,
                            height: 60,
                            radius: 10.0,
                            child: Text(
                              Languages.of(context)!.txtNotReally,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colur.txt_white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.0),
                            ),
                            isShadow: false,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Colur.green_For_NotReally,
                                Colur.green_For_NotReally,
                              ],
                            ),
                            onPressed: () {
                              _textFeedback.text = "";
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: TextField(
                                        controller: _textFeedback,
                                        textInputAction: TextInputAction.done,
                                        minLines: 1,
                                        maxLines: 10,
                                        style: TextStyle(
                                            color: Colur.txt_black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18),
                                        keyboardType: TextInputType.text,
                                        maxLength: 500,
                                        decoration: InputDecoration(
                                          hintText: Languages.of(context)!
                                              .txtWriteSuggestionsHere,
                                          hintStyle: TextStyle(
                                              color: Colur.txt_grey,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(
                                            Languages.of(context)!
                                                .txtCancel
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: Colur.txt_purple,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                            Languages.of(context)!
                                                .txtSubmit
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: Colur.txt_purple,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          onPressed: () {
                                            final Uri emailLaunchUri = Uri(
                                              scheme: 'mailto',
                                              path: '${Constant.EMAIL_PATH}',
                                              query: encodeQueryParameters(<String,
                                                  String>{
                                                'subject': Languages.of(context)!
                                                    .txtRunTrackerFeedback,
                                                'body': '${_textFeedback.text}'
                                              }),
                                            );
                                            launchUrl(
                                                Uri.parse(emailLaunchUri.toString()))
                                                .then((value) =>
                                                Navigator.of(context).pop());

                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            },
                          ),
                          GradientButtonSmall(
                            width: 140,
                            height: 60,
                            radius: 10.0,
                            child: Text(
                              Languages.of(context)!.txtGood,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colur.txt_white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.0),
                            ),
                            isShadow: false,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Colur.green_For_NotReally,
                                Colur.green_For_NotReally,
                              ],
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  isDismissible: true,
                                  enableDrag: false,
                                  builder: (context) {
                                    return Wrap(
                                      children: [
                                        RatingDialog(),
                                      ],
                                    );
                                  });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                alignment: Alignment.topCenter,
                width: 100.0,
                height: 100.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new AssetImage("assets/images/dummy_girl.png")))),
          ]),
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
