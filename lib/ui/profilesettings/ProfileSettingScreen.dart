import 'package:flutter/material.dart';
import 'package:run_tracker/common/commonTopBar/CommonTopBar.dart';
import 'package:run_tracker/custom/bottomsheetdialogs/RatingDialog.dart';
import 'package:run_tracker/interfaces/TopBarClickListener.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/localization/language_data.dart';
import 'package:run_tracker/localization/locale_constant.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ProfileSettingScreen extends StatefulWidget {
  @override
  _ProfileSettingScreenState createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen>
    implements TopBarClickListener {
  List<String>? units;
  String? _unitsChosenValue;
  LanguageData? _languagesChosenValue = LanguageData.languageList()[0];
  List<LanguageData> languages = LanguageData.languageList();
  List<String>? days;
  String? _daysChosenValue =
      DateFormat.EEEE(getLocale().languageCode).dateSymbols.WEEKDAYS[1];
  String? prefLanguage;
  int? prefDayInNum;
  TextEditingController _textFeedback = TextEditingController();

  bool kmSelected = true;

  _getPreference() {
    prefLanguage = Preference.shared.getString(Preference.LANGUAGE);
    if (prefLanguage == null) {
      _languagesChosenValue = languages[9];
    } else {
      _languagesChosenValue = languages
          .where((element) => (element.languageCode == prefLanguage))
          .toList()[0];
    }

    prefDayInNum =
        Preference.shared.getInt(Preference.FIRST_DAY_OF_WEEK_IN_NUM) ?? 1;
    if (prefDayInNum == 1) {
      _daysChosenValue = days![1];
    } else if (prefDayInNum == 0) {
      _daysChosenValue = days![0];
    } else {
      _daysChosenValue = days![2];
    }
    kmSelected = Preference.shared.getBool(Preference.IS_KM_SELECTED) ?? true;
    if (kmSelected == true) {
      _unitsChosenValue = units![0];
    } else {
      _unitsChosenValue = units![1];
    }
  }

  @override
  Widget build(BuildContext context) {
    units = [
      Languages.of(context)!.txtKM.toUpperCase(),
      Languages.of(context)!.txtMile.toUpperCase()
    ];
    if (_unitsChosenValue == null) _unitsChosenValue = units![0];
    if (_languagesChosenValue == null) _languagesChosenValue = languages[9];
    List<String> allDays = DateFormat.EEEE(getLocale().languageCode)
        .dateSymbols
        .STANDALONEWEEKDAYS;
    days = [
      allDays[0],
      allDays[1],
      allDays[6],
    ];
    if (_daysChosenValue == null) _daysChosenValue = days![1];

    _getPreference();

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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/reminder');
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/icons/ic_notification_white.webp",
                                scale: 4,
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: Text(
                                    Languages.of(context)!.txtReminder,
                                    style: TextStyle(
                                        color: Colur.txt_white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: Colur.txt_grey,
                        indent: 20.0,
                        height: 40.0,
                        endIndent: 20.0,
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Text(
                          Languages.of(context)!.txtUnitSettings.toUpperCase(),
                          style: TextStyle(
                              color: Colur.txt_grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/icons/ic_units.webp",
                              scale: 4,
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: Text(
                                  Languages.of(context)!
                                      .txtMetricAndImperialUnits,
                                  style: TextStyle(
                                      color: Colur.txt_white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            DropdownButton<String>(
                              value: _unitsChosenValue,
                              elevation: 2,
                              style: TextStyle(
                                  color: Colur.txt_purple,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400),
                              iconEnabledColor: Colur.white,
                              iconDisabledColor: Colur.white,
                              dropdownColor: Colur.progress_background_color,
                              underline: Container(
                                color: Colur.transparent,
                              ),
                              isDense: true,
                              items: units!.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _unitsChosenValue = value;
                                  Preference.clearMetricAndImperialUnits();
                                  if (_unitsChosenValue ==
                                      Languages.of(context)!
                                          .txtKM
                                          .toUpperCase()) {
                                    kmSelected = true;
                                    Preference.shared.setBool(
                                        Preference.IS_KM_SELECTED, kmSelected);
                                  } else {
                                    kmSelected = false;
                                    Preference.shared.setBool(
                                        Preference.IS_KM_SELECTED, kmSelected);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colur.txt_grey,
                        indent: 20.0,
                        height: 40.0,
                        endIndent: 20.0,
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Text(
                          Languages.of(context)!
                              .txtGeneralSettings
                              .toUpperCase(),
                          style: TextStyle(
                              color: Colur.txt_grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/ic_languages.webp",
                                  scale: 4,
                                ),
                                /*Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: Text(
                                      Languages.of(context)!
                                          .txtLanguageOptions,
                                      style: TextStyle(
                                          color: Colur.txt_white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),*/
                                Expanded(
                                  child: DropdownButton<LanguageData>(
                                    value: _languagesChosenValue,
                                    isExpanded: true,
                                    elevation: 2,
                                    style: TextStyle(
                                        color: Colur.txt_purple,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                    iconEnabledColor: Colur.white,
                                    iconDisabledColor: Colur.white,
                                    dropdownColor:
                                        Colur.progress_background_color,
                                    underline: Container(
                                      color: Colur.transparent,
                                    ),
                                    isDense: true,
                                    items: languages
                                        .map<DropdownMenuItem<LanguageData>>(
                                          (e) => DropdownMenuItem<LanguageData>(
                                            value: e,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, right: 15),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      " " + e.name,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color:
                                                            (_languagesChosenValue ==
                                                                    e)
                                                                ? Colur.white
                                                                : Colur
                                                                    .txt_purple,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    e.flag,
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (LanguageData? value) {
                                      if (value != null)
                                        setState(() {
                                          _languagesChosenValue = value;
                                          Preference.shared.setString(
                                              Preference.LANGUAGE,
                                              _languagesChosenValue!
                                                  .languageCode);
                                          changeLanguage(
                                              context,
                                              _languagesChosenValue!
                                                  .languageCode);
                                        });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 30.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/ic_calender.webp",
                                    scale: 4,
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 25.0),
                                      child: Text(
                                        Languages.of(context)!
                                            .txtFirstDayOfWeek,
                                        style: TextStyle(
                                            color: Colur.txt_white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: _daysChosenValue,
                                    elevation: 2,
                                    style: TextStyle(
                                        color: Colur.txt_purple,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                    iconEnabledColor: Colur.white,
                                    iconDisabledColor: Colur.white,
                                    dropdownColor:
                                        Colur.progress_background_color,
                                    underline: Container(
                                      color: Colur.transparent,
                                    ),
                                    isDense: true,
                                    items: days!.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        _daysChosenValue = value;
                                        Preference.shared.setString(
                                            Preference.FIRST_DAY_OF_WEEK,
                                            _daysChosenValue.toString());
                                        if (_daysChosenValue == days![0]) {
                                          Preference.shared.setInt(
                                              Preference
                                                  .FIRST_DAY_OF_WEEK_IN_NUM,
                                              0);
                                        }
                                        if (_daysChosenValue == days![1]) {
                                          Preference.shared.setInt(
                                              Preference
                                                  .FIRST_DAY_OF_WEEK_IN_NUM,
                                              1);
                                        }
                                        if (_daysChosenValue == days![2]) {
                                          Preference.shared.setInt(
                                              Preference
                                                  .FIRST_DAY_OF_WEEK_IN_NUM,
                                              -1);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colur.txt_grey,
                        indent: 20.0,
                        height: 40.0,
                        endIndent: 20.0,
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Text(
                          Languages.of(context)!.txtSupportUs.toUpperCase(),
                          style: TextStyle(
                              color: Colur.txt_grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      InkWell(
                        onTap: () {
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
                                          .txtFeedbackOrSuggestion,
                                      hintStyle: TextStyle(
                                          color: Colur.txt_grey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18),
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
                                        launchUrl(Uri.parse(
                                                emailLaunchUri.toString()))
                                            .then((value) =>
                                                Navigator.of(context).pop());

                                        setState(() {});
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/icons/ic_email.webp",
                                scale: 4,
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: Text(
                                    Languages.of(context)!.txtFeedback,
                                    style: TextStyle(
                                        color: Colur.txt_white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
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
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/icons/ic_star_white.webp",
                                scale: 4,
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: Text(
                                    Languages.of(context)!.txtRateUs,
                                    style: TextStyle(
                                        color: Colur.txt_white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          launchURLPrivacyPolicy();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/icons/ic_privacy_policy.webp",
                                scale: 4,
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: Text(
                                    Languages.of(context)!.txtPrivacyPolicy,
                                    style: TextStyle(
                                        color: Colur.txt_white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void launchURLPrivacyPolicy() async {
    var url = Constant.getPrivacyPolicyURL();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
    if (name == Constant.STR_BACK) {
      Navigator.pop(context);
    }
  }
}
