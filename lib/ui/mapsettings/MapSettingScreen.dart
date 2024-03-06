import 'package:flutter/material.dart';
import 'package:run_tracker/common/commonTopBar/CommonTopBar.dart';
import 'package:run_tracker/interfaces/TopBarClickListener.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:run_tracker/utils/Preference.dart';

class MapSettingScreen extends StatefulWidget {
  const MapSettingScreen({Key? key}) : super(key: key);

  @override
  _MapSettingScreenState createState() => _MapSettingScreenState();
}

class _MapSettingScreenState extends State<MapSettingScreen>
    implements TopBarClickListener {

  List<String>? units;
  String? _chosenValue;
  bool kmSelected= true;


  _getPreferences(){
    kmSelected =
        Preference.shared.getBool(Preference.IS_KM_SELECTED) ?? true;
    if(kmSelected == true){
      _chosenValue = units![0];
    }
    else{
      _chosenValue = units![1];
    }

  }

  @override
  Widget build(BuildContext context) {
    units = [Languages.of(context)!.txtKM.toUpperCase(), Languages.of(context)!.txtMile.toUpperCase()];
    if (_chosenValue == null) _chosenValue = units![0];
    _getPreferences();

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
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        Languages.of(context)!.txtMetricAndImperialUnits,
                        style: TextStyle(
                            color: Colur.txt_white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _chosenValue,
                      elevation: 2,
                      style: TextStyle(color: Colur.white),
                      iconEnabledColor: Colur.white,
                      iconDisabledColor: Colur.white,
                      dropdownColor: Colur.progress_background_color,
                      underline: Container(
                        color: Colur.transparent,
                      ),
                      isDense: true,

                      items:
                          units!.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _chosenValue = value;

                          if(_chosenValue == Languages.of(context)!.txtKM.toUpperCase()){
                            kmSelected = true;
                            Preference.shared.setBool(Preference.IS_KM_SELECTED, kmSelected);
                          }else{
                            kmSelected = false;
                            Preference.shared.setBool(Preference.IS_KM_SELECTED, kmSelected);
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
      ),
    );
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
    if(name == Constant.STR_BACK){
      Navigator.pop(context);
    }
  }
}