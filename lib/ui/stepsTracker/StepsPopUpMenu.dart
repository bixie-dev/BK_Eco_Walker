import 'package:flutter/material.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';

class StepsPopUpMenu extends ModalRoute<String>{

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Material(
     type: MaterialType.transparency,
     child: SafeArea(
       child: InkWell(
         onTap: () => Navigator.pop(context),
         child: Container(
           margin: EdgeInsets.only(top: 50, right: 20),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Container(
                 height: 141,
                 width: 141,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.all(Radius.circular(10)),
                   color: Colur.white,
                 ),
                 child: Column(

                   children: [
                     buildPopUpItem(
                       icon: "ic_reset.png",
                       text: Languages.of(context)!.txtReset,
                       onTap: () => Navigator.pop(context, Constant.STR_RESET),
                       color: Colur.txt_grey
                     ),
                     buildPopUpItem(
                       icon: "ic_edit.png",
                       text: Languages.of(context)!.txtEditTarget,
                       onTap: () => Navigator.pop(context, Constant.STR_EDIT_TARGET),
                       color: Colur.txt_grey
                     ),
                     buildPopUpItem(
                       icon: "ic_turn_off.png",
                       text: Languages.of(context)!.txtTurnoff,
                       onTap: () => Navigator.pop(context, Constant.STR_TURNOFF),
                       color: Colur.red_turn_off,
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ),
       )
     ),
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }

  buildPopUpItem({String? icon, required String text, Function? onTap, Color? color}) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        margin: EdgeInsets.only(top: 22,  left: 12, right:10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/icons/$icon",
              height: 18,
              width: 14,
              color: color,
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colur.txt_black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}