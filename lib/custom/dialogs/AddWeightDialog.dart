import 'dart:async';

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:run_tracker/dbhelper/DataBaseHelper.dart';
import 'package:run_tracker/dbhelper/datamodel/WeightData.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Utils.dart';

class AddWeightDialog extends StatefulWidget {
  @override
  _AddWeightDialogState createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<AddWeightDialog> {
  DatePickerController _datePickerController = DatePickerController();
  TextEditingController weightController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool isKg = false;
  bool isLsb = false;
  bool isConvert = true;
  int? daysCount;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    isKg = true;
    isLsb = false;
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _datePickerController.animateToSelection();
      });
    });

    startDate = DateTime(
        DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
    endDate = DateTime.now().add(Duration(days: 4));
    daysCount = endDate!.difference(startDate!).inDays;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colur.transparent,
      body: Center(
        child: Wrap(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                  color: Colur.white, borderRadius: BorderRadius.circular(8.0)),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 25.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            var previousMonthDate = DateTime(_selectedDate.year,
                                _selectedDate.month - 1, _selectedDate.day);
                            if (previousMonthDate != startDate) {
                              _datePickerController
                                  .animateToDate(previousMonthDate);
                              setState(() {
                                _selectedDate = previousMonthDate;
                              });
                            }
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 15.0,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            DateFormat("MMMM, yyyy")
                                .format(_selectedDate)
                                .toString(),
                            style: TextStyle(
                                color: Colur.txt_black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            var nextMonthDate = DateTime(_selectedDate.year,
                                _selectedDate.month + 1, _selectedDate.day);
                            if (nextMonthDate !=
                                DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month + 1,
                                    DateTime.now().day)) {
                              _datePickerController
                                  .animateToDate(nextMonthDate);
                              setState(() {
                                _selectedDate = nextMonthDate;
                              });
                            }
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 15.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: DatePicker(
                      DateTime(DateTime.now().year - 1, DateTime.now().month,
                          DateTime.now().day),
                      width: 60,
                      height: 80,
                      daysCount: daysCount!,
                      controller: _datePickerController,
                      initialSelectedDate: DateTime.now(),
                      selectionColor: Colur.txt_purple,
                      selectedTextColor: Colur.txt_white,
                      monthTextStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.0,
                        color: Colur.txt_black,
                      ),
                      dateTextStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                        color: Colur.txt_black,
                      ),
                      dayTextStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.0,
                        color: Colur.txt_black,
                      ),
                      deactivatedColor: Colors.black26,
                      inactiveDates: [
                        DateTime.now().add(Duration(days: 1)),
                        DateTime.now().add(Duration(days: 2)),
                        DateTime.now().add(Duration(days: 3)),
                      ],
                      onDateChange: (date) {
                        setState(() {
                          _selectedDate = date;
                          Debug.printLog(
                              "Updated Date ==> " + _selectedDate.toString());
                        });
                      },
                    ),
                  ),
                  Divider(
                    thickness: 2,
                    color: Colors.grey.shade300,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 25.0, right: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 25.0),
                            child: TextFormField(
                              controller: weightController,
                              maxLines: 1,
                              maxLength: 5,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,1}')),
                              ],
                              style: TextStyle(
                                  color: Colur.txt_black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500),
                              cursorColor: Colur.txt_grey,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(0.0),
                                hintText: "0.0",
                                hintStyle: TextStyle(
                                    color: Colur.txt_grey,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colur.txt_black),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colur.txt_black),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colur.txt_black),
                                ),
                              ),
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isKg = true;
                              isLsb = false;
                            });
                            if (!isConvert) {
                              isConvert = true;
                              if (weightController.text == "")
                                weightController.text = "0.0";
                              Debug.printLog(
                                  "Before converted value of weightController --> " +
                                      weightController.text);
                              weightController.text = Utils.lbToKg(double.parse(
                                      weightController.text.toString()))
                                  .toString();
                              Debug.printLog(
                                  "After converted value of weightController in to LB to KG --> " +
                                      weightController.text);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 20.0),
                            padding: const EdgeInsets.all(5.0),
                            decoration: (isKg)
                                ? BoxDecoration(
                                    color: Colur.txt_purple,
                                    borderRadius: BorderRadius.circular(5.0),
                                  )
                                : BoxDecoration(
                                    border: Border.all(
                                      color: Colur.txt_black,
                                    ),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                            child: Text(
                              Languages.of(context)!.txtKG.toUpperCase(),
                              style: TextStyle(
                                  color: (isKg)
                                      ? Colur.txt_white
                                      : Colur.txt_black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isKg = false;
                              isLsb = true;
                            });
                            if (isConvert) {
                              isConvert = false;
                              if (weightController.text == "")
                                weightController.text = "0.0";
                              Debug.printLog(
                                  "Before converted value of weightController --> " +
                                      weightController.text);
                              weightController.text = Utils.kgToLb(double.parse(
                                      weightController.text.toString()))
                                  .toString();
                              Debug.printLog(
                                  "After converted value of weightController in to KG to LB --> " +
                                      weightController.text);
                            }
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.only(right: 15.0, left: 10.0),
                            padding: const EdgeInsets.all(5.0),
                            decoration: (isLsb)
                                ? BoxDecoration(
                                    color: Colur.txt_purple,
                                    borderRadius: BorderRadius.circular(5.0),
                                  )
                                : BoxDecoration(
                                    border: Border.all(
                                      color: Colur.txt_black,
                                    ),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                            child: Text(
                              Languages.of(context)!.txtLB.toUpperCase(),
                              style: TextStyle(
                                  color: (isLsb)
                                      ? Colur.txt_white
                                      : Colur.txt_black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 50.0, bottom: 25.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              Languages.of(context)!.txtCancel,
                              style: TextStyle(
                                  color: Colur.txt_purple,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if(isKg && !isLsb){
                              if (double.parse(weightController.text.toString()) >= Constant.MIN_KG && double.parse(weightController.text.toString()) <= Constant.MAX_KG){
                                setState(() {
                                  DataBaseHelper.insertWeight(WeightData(
                                    id: null,
                                    weightKg: (isKg && !isLsb) ? double.parse(weightController.text.toString()) : Utils.lbToKg(double.parse(weightController.text.toString())),
                                    weightLbs: (!isKg && isLsb) ? double.parse(weightController.text.toString()) : Utils.kgToLb(double.parse(weightController.text.toString())),
                                    date: DateFormat.yMd().format(_selectedDate),
                                  ));
                                  Navigator.pop(context);
                                });
                              }else{
                                Utils.showToast(context, Languages.of(context)!.txtWarningForKg);
                              }
                            }else{
                              if (double.parse(weightController.text.toString()) >= Constant.MIN_LBS && double.parse(weightController.text.toString()) <= Constant.MAX_LBS) {
                                setState(() {
                                  DataBaseHelper.insertWeight(WeightData(
                                    id: null,
                                    weightKg: (isKg && !isLsb) ? double.parse(weightController.text.toString()) : Utils.lbToKg(double.parse(weightController.text.toString())),
                                    weightLbs: (!isKg && isLsb) ? double.parse(weightController.text.toString()) : Utils.kgToLb(double.parse(weightController.text.toString())),
                                    date: DateFormat.yMd().format(_selectedDate),
                                  ));
                                  Navigator.pop(context);
                                });
                              }else{
                                Utils.showToast(context, Languages.of(context)!.txtWarningForLbs);
                              }
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 20.0, left: 10.0),
                            child: Text(
                              Languages.of(context)!.txtSave,
                              style: TextStyle(
                                  color: Colur.txt_purple,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
