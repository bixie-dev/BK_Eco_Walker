import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:run_tracker/common/commonTopBar/CommonTopBar.dart';
import 'package:run_tracker/dbhelper/datamodel/RunningData.dart';
import 'package:run_tracker/interfaces/TopBarClickListener.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';
import 'dart:ui' as ui;

import 'package:share_plus/share_plus.dart';

class ShareScreen extends StatefulWidget {
  final RunningData? runningData;

  ShareScreen(this.runningData);

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> implements TopBarClickListener {

  GlobalKey previewContainer = new GlobalKey();
  bool kmSelected = true;
  RunningData? runningData;


  @override
  void initState() {
    super.initState();
    if(widget.runningData == null)
      runningData = RunningData(id: -1,duration: 120,distance: 150.0,speed: 5.0,cal:70.5);
    else
      runningData = widget.runningData;
    _getPreferences();
  }

  _getPreferences(){
    setState(() {
      kmSelected =
          Preference.shared.getBool(Preference.IS_KM_SELECTED) ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colur.common_bg_dark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  child: CommonTopBar(
                    Languages.of(context)!.txtShare,
                    this,
                    isShowBack: true,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: 15,horizontal: 25
                  ),
                  child: RepaintBoundary(
                    key: previewContainer,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Image.file(
                                runningData!.getImage()!,
                                errorBuilder: (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stackTrace,
                                    ) {
                                  return Image.asset(
                                    'assets/images/dummy_map.png',
                                    height: MediaQuery.of(context).size.height*0.5,
                                    fit: BoxFit.cover,
                                  );
                                },
                                fit: BoxFit.cover,
                              ),
                              /*(runningData!.image != null)?Image.file(
                                File(runningData!.image!),fit: BoxFit.contain,): Image.asset(
                                'assets/images/dummy_map.png',
                                fit: BoxFit.cover,
                              ),*/
                              Container(
                                margin: EdgeInsets.only(left: 15),
                                child: Image.asset(
                                  'assets/icons/ic_share_watermark.png',
                                  scale: 3.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 25, bottom: 20),
                            color: Colur.blue_gredient_1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Text(
                                        Utils.secToString(runningData!.duration!),
                                        style: TextStyle(
                                            color: Colur.txt_white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 24),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        Languages.of(context)!.txtTime.toUpperCase() +
                                            " (${Languages.of(context)!.txtMin.toUpperCase()})",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colur.txt_white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Text(
                                            (kmSelected)? runningData!.speed!.toStringAsFixed(2):Utils.minPerKmToMinPerMile(runningData!.speed!).toStringAsFixed(2),
                                            style: TextStyle(
                                                color: Colur.txt_white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 24),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            (kmSelected)?Languages.of(context)!.txtPaceMinPer+Languages.of(context)!.txtKM.toUpperCase()+")":Languages.of(context)!.txtPaceMinPer+Languages.of(context)!.txtMile.toUpperCase()+")",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colur.txt_white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Text(
                                          runningData!.cal.toString(),
                                          style: TextStyle(
                                              color: Colur.txt_white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 24),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          Languages.of(context)!.txtKCAL,
                                          style: TextStyle(
                                              color: Colur.txt_white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    screenShotAndShare();
                  },
                  child:Container(
                    height: 90,
                    width: 90,
                    margin: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(shape: BoxShape.circle,gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Colur.purple_gradient_color1,
                        Colur.purple_gradient_color2,
                      ],
                    ), ),
                    child: Icon(Icons.share,size: 40,color: Colur.white,),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> screenShotAndShare() async {

    try {
      RenderRepaintBoundary boundary = previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 2.0);

      late String _localPath;
      _localPath =
          (await _findLocalPath())! + Platform.pathSeparator + 'Download';

      final savedDir = Directory(_localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
        Debug.printLog(savedDir.toString());
      }

      ByteData byteData = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      Uint8List pngBytes = byteData.buffer.asUint8List();
      File imgFile = await File(savedDir.path + Platform.pathSeparator + DateTime.now().millisecondsSinceEpoch.toString()+'_ss.png').create(recursive: true);
      await imgFile.writeAsBytes(pngBytes);
      final RenderBox box = context.findRenderObject() as RenderBox;
      Share.shareXFiles([XFile(imgFile.path)],
          subject: Languages.of(context)!.appName,
          text: Languages.of(context)!.txtShareMapMsg,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size
      );
    } on PlatformException catch (e) {
      print("Exception while taking screenshot:" + e.toString());
    } on Exception catch(e){
      print("Exception while taking screenshot:" + e.toString());
    }

  }

  Future<String?> _findLocalPath() async {
    final TargetPlatform plateform2 = Theme.of(context).platform;
    final directory = (plateform2 == TargetPlatform.android)
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory?.path;
  }

  @override
  void onTopBarClick(String name, {bool value = true}) {
    if (name == Constant.STR_BACK) {
      Navigator.of(context).pop();
    }
  }
}
