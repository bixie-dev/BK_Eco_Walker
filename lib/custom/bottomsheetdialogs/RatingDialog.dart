import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '../../localization/language/languages.dart';
import '../../utils/Color.dart';
import '../../utils/Debug.dart';
import '../GradientButtonSmall.dart';

class RatingDialog extends StatefulWidget {
  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double rating;
  String? emoji;
  late String emojiTitle;
  String? btnTitle;
  RateMyApp? rateMyApp;

  @override
  void initState() {
    rating = 4.0;
    _ratingDialog();
    emoji = 'assets/icons/ic_emoji_good.webp';
    super.initState();
  }

  _ratingDialog() {
    rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 7,
      minLaunches: 10,
      remindDays: 7,
      remindLaunches: 10,
      googlePlayIdentifier: 'Enter your googlePlayIdentifier here',
      appStoreIdentifier: 'Enter your appStoreIdentifier here',
    );

    rateMyApp!.init().then((_) {
      if (rateMyApp!.shouldOpenDialog) {
        rateMyApp!.showRateDialog(
          context,
          title: 'Rate this app',
          message:
              'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
          rateButton: 'RATE',
          noButton: 'NO THANKS',
          laterButton: 'MAYBE LATER',
          listener: (button) {
            switch (button) {
              case RateMyAppDialogButton.rate:
                print('Clicked on "Rate".');
                break;
              case RateMyAppDialogButton.later:
                print('Clicked on "Later".');
                break;
              case RateMyAppDialogButton.no:
                print('Clicked on "No".');
                break;
            }
            return true;
          },
          ignoreNativeDialog: Platform.isAndroid,
          dialogStyle: const DialogStyle(),
          onDismissed: () =>
              rateMyApp!.callEvent(RateMyAppEventType.laterButtonPressed),
        );

        rateMyApp!.showStarRateDialog(
          context,
          title: 'Rate this app',
          message:
              'You like this app ? Then take a little bit of your time to leave a rating :',
          actionsBuilder: (context, stars) {
            return [
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  Debug.printLog('Thanks for the ' +
                      (stars == null ? '0' : stars.round().toString()) +
                      ' star(s) !');
                  await rateMyApp!
                      .callEvent(RateMyAppEventType.rateButtonPressed);
                  Navigator.pop<RateMyAppDialogButton>(
                      context, RateMyAppDialogButton.rate);
                },
              ),
            ];
          },
          ignoreNativeDialog: Platform.isAndroid,
          dialogStyle: const DialogStyle(
            titleAlign: TextAlign.center,
            messageAlign: TextAlign.center,
            messagePadding: EdgeInsets.only(bottom: 20),
          ),
          starRatingOptions: const StarRatingOptions(),
          onDismissed: () =>
              rateMyApp!.callEvent(RateMyAppEventType.laterButtonPressed),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (emoji == 'assets/icons/ic_emoji_good.webp')
      emojiTitle = Languages.of(context)!.txtGood;
    if (btnTitle == null)
      btnTitle = Languages.of(context)!.txtRate.toUpperCase();
    return Container(
      color: Colur.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colur.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            margin: EdgeInsets.only(top: 60.0),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 80.0, left: 20.0, right: 20.0),
                    child: Text(
                      emojiTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          letterSpacing: 0,
                          color: Colur.txt_black,
                          fontWeight: FontWeight.w700,
                          fontSize: 28),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 35),
                    child: RatingBar.builder(
                      initialRating: rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 50.0,
                      glowRadius: 0.1,
                      glowColor: Colur.txt_grey,
                      itemPadding: EdgeInsets.symmetric(horizontal: 5.0),
                      unratedColor: Colur.unselected_star,
                      itemBuilder: (context, _) => Image.asset(
                        "assets/icons/ic_star.webp",
                        color: Colur.selected_star,
                      ),
                      onRatingUpdate: (rating) {
                        Debug.printLog("Rating ==>" + rating.toString());
                        setState(() {
                          if (rating <= 1.0) {
                            emoji = 'assets/icons/ic_emoji_terrible.webp';
                            emojiTitle = Languages.of(context)!.txtTerrible;
                            btnTitle =
                                Languages.of(context)!.txtRate.toUpperCase();
                          } else if (rating <= 2.0) {
                            emoji = 'assets/icons/ic_emoji_bad.webp';
                            emojiTitle = Languages.of(context)!.txtBad;
                            btnTitle =
                                Languages.of(context)!.txtRate.toUpperCase();
                          } else if (rating <= 3.0) {
                            emoji = 'assets/icons/ic_emoji_okay.webp';
                            emojiTitle = Languages.of(context)!.txtOkay;
                            btnTitle =
                                Languages.of(context)!.txtRate.toUpperCase();
                          } else if (rating <= 4.0) {
                            emoji = 'assets/icons/ic_emoji_good.webp';
                            emojiTitle = Languages.of(context)!.txtGood;
                            btnTitle =
                                Languages.of(context)!.txtRate.toUpperCase();
                          } else if (rating <= 5.0) {
                            emoji = 'assets/icons/ic_emoji_great.webp';
                            emojiTitle = Languages.of(context)!.txtGreat;
                            btnTitle = Languages.of(context)!
                                .txtRatingOnGooglePlay
                                .toUpperCase();
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
                    child: Text(
                      Languages.of(context)!.txtBestWeCanGet + " :)",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colur.txt_grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 18),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 40.0, left: 80.0, right: 80.0, bottom: 60.0),
                    child: GradientButtonSmall(
                      width: double.infinity,
                      height: 55,
                      radius: 50.0,
                      child: Text(
                        btnTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colur.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0),
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
                        rateMyApp!
                            .showRateDialog(context)
                            .then((value) => Navigator.pop(context));
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
            child: Image.asset(
              emoji!,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}
