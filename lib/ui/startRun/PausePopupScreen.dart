import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:run_tracker/dbhelper/datamodel/RunningData.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'StartRunScreen.dart';

class PausePopupScreen extends ModalRoute<String> {

  StopWatchTimer? stopWatchTimer;
  bool? startTrack;
  RunningData? runningData;
  GoogleMapController? controller2;
  Set<Marker>? markers;

   PausePopupScreen(this.stopWatchTimer, this.startTrack, this.runningData, this.controller2, this.markers);

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.7);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,) {
    var fullheight = MediaQuery
        .of(context)
        .size
        .height;
    return Material(
      type: MaterialType.transparency,
      child: _buildOverlayContent(context, fullheight,runningData,controller2,markers!),
    );
  }


  Widget _buildOverlayContent(BuildContext context, var fullheight,RunningData? runningData,GoogleMapController? controller2, Set<Marker> markers) {
    return Container(

      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: fullheight * 0.10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              print(startTrack.toString());
              Navigator.pop(context, 'false');
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_sharp, color: Colur.txt_white, size: 20,),
                  Container(
                    margin: EdgeInsets.only(left: 4),
                    child: Text(Languages
                        .of(context)!
                        .txtRestart
                        .toUpperCase(), style: TextStyle(fontSize: 20,
                        color: Colur.white,
                        fontWeight: FontWeight.w700),),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          customDialog(context,runningData,controller2,markers));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Colur.light_red_stop_gredient1,
                            Colur.light_red_stop_gredient2,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          child: Image.asset(
                            "assets/icons/ic_square.png",
                            scale: 3.7,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(Languages.of(context)!.txtStop.toUpperCase(), style: TextStyle(fontSize: 16,
                          color: Colur.txt_white,
                          fontWeight: FontWeight.w600),),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: () {
                  // stopWatchTimer!.onExecute.add(StopWatchExecute.start);
                  stopWatchTimer!.onStartTimer();
                  Navigator.pop(context,'true');
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Colur.light_green_play_gredient1,
                            Colur.light_green_play_gredient2,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          child: Image.asset(
                            "assets/icons/ic_play.png",
                            scale: 3.7,
                            color: Colur.txt_white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(Languages
                          .of(context)!
                          .txtResume.toUpperCase(), style: TextStyle(fontSize: 16,
                          color: Colur.txt_white,
                          fontWeight: FontWeight.w600),),
                    ),
                  ],
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }

  Widget customDialog(BuildContext context,RunningData? runningData,GoogleMapController? controller2, Set<Marker> markers) {
    return Dialog(
      elevation: 30,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            color: Colur.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: []),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.topLeft,
                child: Image.asset('assets/icons/ic_close.png',color: Colur.txt_black,scale: 3.5,)
              ),
            ),
            Container(
                height: 200,
                child: Image.asset('assets/images/finish_image.png',
                )),
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 40),
              child: Center(
                child: Text(Languages
                    .of(context)!
                    .txtFinishTraining
                    .toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colur.txt_black,
                      fontWeight: FontWeight.w900, fontSize: 20),),
              ),
            ),
            InkWell(
              onTap: () async {
                StartRunScreen.runningStopListener!.onFinish(value: true);

              },
              child: Container(
                margin: EdgeInsets.only(top: 15.0,),
                padding: EdgeInsets.symmetric(vertical: 15.0,),
                width: 250,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colur.purple_gradient_color1,
                      Colur.purple_gradient_color2,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(Languages
                      .of(context)!
                      .txtFinish
                      .toUpperCase(),
                    style: TextStyle(
                        color: Colur.txt_white,
                        fontWeight: FontWeight.w900, fontSize: 20),),
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
          ],
        ),
      ),
    );
  }
}