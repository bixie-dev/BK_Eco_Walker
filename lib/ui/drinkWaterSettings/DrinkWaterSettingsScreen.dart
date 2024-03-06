import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:run_tracker/ad_helper.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/ui/drinkWaterReminder/DrinkWaterReminderScreen.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';

import '../../common/commonTopBar/CommonTopBar.dart';
import '../../interfaces/TopBarClickListener.dart';
import '../../utils/Constant.dart';

class DrinkWaterSettingsScreen extends StatefulWidget {
  @override
  _DrinkWaterSettingsScreenState createState() =>
      _DrinkWaterSettingsScreenState();
}

class _DrinkWaterSettingsScreenState extends State<DrinkWaterSettingsScreen>
    implements TopBarClickListener {
  String? targetValue;
  bool isReminder = false;
  late List<String> targetList;
  var fullHeight;
  var fullWidth;
  var prefTargetValue;

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    targetList = [
      '500',
      '1000',
      '1500',
      '2000',
      '2500',
      '3000',
      '3500',
      '4000',
      '4500',
      '5000'
    ];
    _getPreferences();
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


  _getPreferences() {
    prefTargetValue =
        Preference.shared.getString(Preference.TARGET_DRINK_WATER);
    if (targetValue == null && prefTargetValue == null) {
      targetValue = targetList[3];
    } else {
      targetValue = prefTargetValue;
    }
    isReminder = Preference.shared.getBool(Preference.IS_REMINDER_ON) ?? false;
  }

  _onRefresh() {
    setState(() {});
    _getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    fullHeight = MediaQuery.of(context).size.height;
    fullWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colur.common_bg_dark,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Container(
                child: CommonTopBar(
                  Languages.of(context)!.txtSettings,
                  this,
                  isShowBack: true,
                ),
              ),

              buildListView(context),

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
        ),
      ),
    );
  }

  buildListView(BuildContext context) {
    return Expanded(
      child: Container(
          margin: EdgeInsets.only(top: 20),
          child: Container(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    Languages.of(context)!.txtTarget,
                    style: TextStyle(
                        color: Colur.txt_white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    Languages.of(context)!.txtTargetDesc,
                    style: TextStyle(
                        color: Colur.txt_grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  trailing: DropdownButton(
                    dropdownColor: Colur.progress_background_color,
                    underline: Container(
                      color: Colur.transparent,
                    ),
                    value: targetValue,
                    //targetValue,
                    iconEnabledColor: Colur.white,
                    items:
                        targetList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          "$value ml",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colur.txt_white,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (dynamic value) {
                      setState(() {
                        Preference.clearTargetDrinkWater();
                        targetValue = value;
                        Preference.shared.setString(Preference.TARGET_DRINK_WATER,
                            targetValue.toString());
                      });
                    },
                  ),
                ),
                Divider(
                  color: Colur.txt_grey,
                  indent: fullWidth * 0.04,
                  endIndent: fullWidth * 0.04,
                ),
                InkWell(
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => DrinkWaterReminderScreen()))
                      .then((value) => _onRefresh()),
                  child: ListTile(
                    title: Text(
                      Languages.of(context)!.txtReminder,
                      style: TextStyle(
                          color: Colur.txt_white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                    trailing:Container(
                      padding: EdgeInsets.only(right: 10),
                      child: Image.asset(
                        "assets/icons/ic_arrow_green_gradient.png",
                        color: Colur.white,
                        height: 20,
                        width: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
    if (name == Constant.STR_BACK) {
      Navigator.of(context).pop();
    }
  }
}
