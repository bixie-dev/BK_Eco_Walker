import 'package:flutter/material.dart';
import 'package:run_tracker/custom/GradientButtonSmall.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/utils/Color.dart';

class WelcomeDialogScreen extends StatefulWidget {
  @override
  _WelcomeDialogScreenState createState() => _WelcomeDialogScreenState();
}

class _WelcomeDialogScreenState extends State<WelcomeDialogScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colur.common_bg_dark,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colur.common_bg_dark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              margin: EdgeInsets.only(top: 60.0),
              child: Container(
                padding: EdgeInsets.only(left: 18.0, right: 18.0, top: 100.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      Languages.of(context)!.txtWelcomeMapRunnner+ Languages.of(context)!.appName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(letterSpacing: 0,
                          color: Colur.txt_white,
                          fontWeight: FontWeight.w700,
                          fontSize: 28),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:30.0,bottom: 30),
                      child: Text(
                        Languages.of(context)!.txtImKateYourCoach,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colur.txt_grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:8.0),
                      child: Text(
                        Languages.of(context)!.txtBottomSheetDescription,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colur.txt_grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 20),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 60.0,right: 60.0,bottom: 60.0,top: 60.0),
                      child: GradientButtonSmall(
                        width: double.infinity,
                        height: 60,
                        radius: 50.0,
                        child: Text(
                          Languages.of(context)!.txtOk,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colur.white, fontWeight: FontWeight.w500,fontSize: 18.0),
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
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 120.0,
              width: 120.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                color: Colur.common_bg_dark,
              ),
              child: Image.asset(
                'assets/images/dummy_girl.png',
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      );
  }
}