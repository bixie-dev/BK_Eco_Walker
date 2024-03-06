import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:run_tracker/custom/GradientButtonSmall.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/ui/wizardScreen/WizardScreen.dart';
import 'package:run_tracker/utils/Color.dart';


class WeightScreen extends StatefulWidget {
  final PageController? pageController;
  final Function? updatevalue;
  final bool? isBack;
  final Function? pageNum;

  final WizardScreenState wizardScreenState;
  final int? weight;
  final Function onWeight;

  WeightScreen({
    this.pageController,
    this.updatevalue,
    this.isBack = true,
    this.pageNum,
    required this.wizardScreenState,
    required this.weight,
    required this.onWeight
  });

  @override
  _WeightScreenState createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {

  bool kgSelected = true;
  bool lbsSelected = false;

  bool unit = true;
  int? weightKG = 60;
  int weightLBS = 44;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var fullHeight =  MediaQuery.of(context).size.height;
    var fullWidth =  MediaQuery.of(context).size.width;
    return Container(
      height: fullHeight,
      width: fullWidth,
      color: Colur.common_bg_dark,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.only(top: fullHeight*0.05),
            child: Text(
              Languages
                  .of(context)!
                  .txtHowMuchDoYouWeight,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colur.txt_white,
                  fontSize: 30),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              Languages
                  .of(context)!
                  .txtHeightDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colur.txt_grey,
                fontSize: 20,
              ),
            ),
          ),

          weightUnitPicker(fullHeight),

          weightSelector(fullHeight),

          Container(
            margin: EdgeInsets.only(left: fullWidth*0.15, bottom: fullHeight*0.08, right: fullWidth*0.15),
            alignment: Alignment.bottomCenter,

            child: GradientButtonSmall(
              width: double.infinity,
              height: 60,
              radius: 50.0,
              child: Text(
                Languages
                    .of(context)!
                    .txtNextStep.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colur.txt_white,
                    fontWeight: FontWeight.w500,
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

                setState(() {
                  widget.updatevalue!(1.0);
                  widget.pageNum!(3);
                });

                convert();
                widget.onWeight(weightKG);


                widget.pageController!.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),

        ],
      ),
    );
  }

  weightUnitPicker(double fullHeight) {
    return Container(
      margin: EdgeInsets.only(top: fullHeight*0.03),
      height: 60,
      width: 205,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colur.txt_grey, width: 1.5),
        color: Colur.progress_background_color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                kgSelected = true;
                lbsSelected = false;
                unit = true;
              });
            },
            child: Container(
              width: 100,
              child: Center(
                child: Text(
                  Languages.of(context)!.txtKG.toUpperCase(),
                  style: TextStyle(
                      color: kgSelected ? Colur.txt_white: Colur.txt_grey,
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
                kgSelected = false;
                lbsSelected = true;
                unit = false;
              });
            },
            child: Container(
              width: 100,
              child: Center(
                child: Text(
                  Languages.of(context)!.txtLBS.toUpperCase(),
                  style: TextStyle(
                      color: lbsSelected ? Colur.txt_white : Colur.txt_grey,
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

  weightSelector(double fullHeight) {
    if(unit == false) {
      return Expanded(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.only(bottom: fullHeight * 0.025),
                  child: Image.asset(
                    "assets/icons/ic_select_pointer.png",
                  ),
                ),
              ),
              Container(
                width: 125,
                height: fullHeight * 0.32,
                child: CupertinoPicker(
                  useMagnifier: true,
                  magnification: 1.05,
                  selectionOverlay:
                  CupertinoPickerDefaultSelectionOverlay(
                    background: Colur.transparent,
                  ),
                  scrollController:
                  FixedExtentScrollController(initialItem: 0),
                  looping: true,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      value += 44;
                      weightLBS = value;
                    });
                  },
                  itemExtent: 75.0,
                  children: List.generate(2155, (index) {
                    index += 44;
                    return Text(
                      "$index",
                      style: TextStyle(
                          color: Colur.txt_white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold),
                    );
                  }),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.only(bottom: fullHeight * 0.025),
                  child: Image.asset(
                    "assets/icons/ic_select_pointer.png",
                  ),
                ),
              ),
              Container(
                width: 125,
                height: fullHeight * 0.32,
                child: CupertinoPicker(
                  useMagnifier: true,
                  magnification: 1.05,
                  selectionOverlay:
                  CupertinoPickerDefaultSelectionOverlay(
                    background: Colur.transparent,
                  ),
                  looping: true,
                  scrollController:
                  FixedExtentScrollController(initialItem: 0),
                  onSelectedItemChanged: (value) {
                    setState(() {
                      value += 20;
                      weightKG = value;
                    });
                  },
                  itemExtent: 75.0,
                  children: List.generate(200, (index) {
                    index += 60;
                    return Text(
                      "$index",
                      style: TextStyle(
                          color: Colur.txt_white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  convert() {
    if(unit == false) {
      var w = weightLBS *0.45;
      weightKG = w.toInt();
    }
  }
}