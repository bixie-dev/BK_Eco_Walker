import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:run_tracker/ad_helper.dart';
import 'package:run_tracker/common/commonTopBar/CommonTopBar.dart';
import 'package:run_tracker/dbhelper/DataBaseHelper.dart';
import 'package:run_tracker/dbhelper/datamodel/RunningData.dart';
import 'package:run_tracker/interfaces/TopBarClickListener.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/ui/runhistorydetails/RunHistoryDetailScreen.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:intl/intl.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';

class RecentActivitiesScreen extends StatefulWidget {
  @override
  _RecentActivitiesScreenState createState() => _RecentActivitiesScreenState();
}

class _RecentActivitiesScreenState extends State<RecentActivitiesScreen>
    implements TopBarClickListener {
  List<RunningData> activityList = [];
  bool activityShow = false;
  bool kmSelected = true;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    _checkData();
    _getPreferences();
    //_loadBanner();
    super.initState();
  }
  _getPreferences(){
    setState(() {
      kmSelected =
          Preference.shared.getBool(Preference.IS_KM_SELECTED) ?? true;
    });
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

  _checkData() async {
    final result = await DataBaseHelper.selectMapHistory();
    activityList.addAll(result);


    if (result.isEmpty || result.length == 0) {
      setState(() {
        activityShow = false;
      });
    } else {
      setState(() {
        activityShow = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var fullHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colur.common_bg_dark,
      body: Container(
        child: Column(
          children: [
            Container(
              child: CommonTopBar(
                Languages.of(context)!.txtRecentActivities,
                this,
                isShowBack: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Visibility(
                      visible: activityShow,
                      child: recentActivitiesList(fullHeight),
                    ),
                    Visibility(
                      visible: !activityShow,
                      child: Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.4),
                        child: Text(
                          Languages.of(context)!.txtNoDataFound,
                          style: TextStyle(
                              color: Colur.purple_gradient_color2,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //if (_isBannerAdReady)
            if (false)
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
    );
  }

  recentActivitiesList(double fullHeight) {
    return Container(
      child: ListView.builder(
          itemCount: activityList.length,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          reverse: true,
          itemBuilder: (BuildContext context, int index) {
            return _activitiesView(context, index, fullHeight);
          }),
    );
  }

  _activitiesView(BuildContext context, int index, double fullheight) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RunHistoryDetailScreen(activityList[index])));
      },
      child: Container(
        margin: EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
          color: Colur.progress_background_color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(13.0),
          child: Row(
            children: [
              ClipRRect(
                child: Image.file(
                  activityList[index].getImage()!,
                  errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                      ) {
                    return Image.asset(
                      "assets/icons/ic_route_map.png",
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    );
                  },
                  height: 90,
                  width: 90,
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.yMMMd().format(DateTime.now()),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colur.txt_white),
                      ),
                      Row(
                        children: [
                          Text(
                          (kmSelected)?activityList[index].distance!.toStringAsFixed(2):Utils.kmToMile(activityList[index].distance!).toStringAsFixed(2),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 21,
                                color: Colur.txt_white),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 4),
                            child: Text(
                              (kmSelected)?Languages.of(context)!.txtKM:Languages.of(context)!.txtMile,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colur.txt_white),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: fullheight * 0.01),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Utils.secToString(activityList[index].duration!),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colur.txt_grey),
                            ),
                            Text(
                              activityList[index].speed != null ? activityList[index].speed!.toString() : "Infinity",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colur.txt_grey),
                            ),
                            Row(
                              children: [
                                Text(
                                  activityList[index].cal!.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colur.txt_grey),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 3.0),
                                  child: Text(
                                    Languages.of(context)!.txtKcal,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Colur.txt_grey),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
    if (name == Constant.STR_BACK) {
      Navigator.pop(context);
    }
  }
}
