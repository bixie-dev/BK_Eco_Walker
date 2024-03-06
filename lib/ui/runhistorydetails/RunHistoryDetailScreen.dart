import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:run_tracker/dbhelper/DataBaseHelper.dart';
import 'package:run_tracker/dbhelper/datamodel/RunningData.dart';
import 'package:run_tracker/localization/language/languages.dart';
import 'package:run_tracker/ui/shareScreen/ShareScreen.dart';
import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class RunHistoryDetailScreen extends StatefulWidget {
  final RunningData recentActivitiesData;

  RunHistoryDetailScreen(this.recentActivitiesData, {Key? key})
      : super(key: key);

  @override
  _RunHistoryDetailScreenState createState() => _RunHistoryDetailScreenState();
}

class _RunHistoryDetailScreenState extends State<RunHistoryDetailScreen> {
  SolidController _solidController = SolidController();

  bool setaliteEnable = false;
  GoogleMapController? _controller;
  LatLng? _startLatLong;
  LatLng? _endLatLong;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> _polylineList = [];
  Set<Marker> markers = {};
  bool kmSelected = true;

  @override
  void initState() {
    super.initState();
    _getPointsAndDrawPolyLines();
    _getPreferences();
  }

  _getPreferences() {
    setState(() {
      kmSelected = Preference.shared.getBool(Preference.IS_KM_SELECTED) ?? true;
    });
  }

  _getPointsAndDrawPolyLines() async {
    _startLatLong = LatLng(double.parse(widget.recentActivitiesData.sLat!),
        double.parse(widget.recentActivitiesData.sLong!));
    _endLatLong = LatLng(double.parse(widget.recentActivitiesData.eLat!),
        double.parse(widget.recentActivitiesData.eLong!));

    final Uint8List markerIcon1 =
        await getBytesFromAsset('assets/icons/ic_map_pin_purple.png', 50);
    final Uint8List markerIcon2 =
        await getBytesFromAsset('assets/icons/ic_map_pin_red.png', 50);
    setState(() {
      final Marker marker1 = Marker(
          icon: BitmapDescriptor.fromBytes(markerIcon1),
          markerId: MarkerId('1'),
          position: _startLatLong!);
      final Marker marker2 = Marker(
          icon: BitmapDescriptor.fromBytes(markerIcon2),
          markerId: MarkerId('2'),
          position: _endLatLong!);
      markers.add(marker1);
      markers.add(marker2);
    });

    Debug.printLog(widget.recentActivitiesData.polyLine!);
    _drawPolyLines();
  }

  _drawPolyLines() {
    _polylineList = widget.recentActivitiesData.getPolyLineData()!;
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: _polylineList,
      width: 4,
    );
    polylines[id] = polyline;

    _animateCameraToPosition(_controller);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    var fulheight = MediaQuery.of(context).size.height;
    var fullwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colur.common_bg_dark,
      body: Container(
        width: fullwidth,
        height: fulheight,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: Colur.txt_grey,
                child: _mapView(fulheight, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _animateCameraToPosition(_controller);
  }

  _animateCameraToPosition(GoogleMapController? _controller) {
    LatLngBounds boundsFromLatLngList(List<LatLng> list) {
      assert(list.isNotEmpty);
      double? x0;
      double? x1;
      double? y0;
      double? y1;
      for (LatLng latLng in list) {
        if (x0 == null) {
          x0 = x1 = latLng.latitude;
          y0 = y1 = latLng.longitude;
        } else {
          if (latLng.latitude > x1!) x1 = latLng.latitude;
          if (latLng.latitude < x0) x0 = latLng.latitude;
          if (latLng.longitude > y1!) y1 = latLng.longitude;
          if (latLng.longitude < y0!) y0 = latLng.longitude;
        }
      }
      return LatLngBounds(
          northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
    }

    Future.delayed(Duration(milliseconds: 10)).then((value) {
      jsonEncode(_polylineList);
      LatLngBounds latLngBounds = boundsFromLatLngList(_polylineList);
      _controller!
          .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 100));
    });
  }

  _mapView(double fullheight, BuildContext context) {
    return Container(
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _startLatLong!, zoom: 15),
            mapType:
                setaliteEnable == true ? MapType.satellite : MapType.normal,
            onMapCreated: _onMapCreated,
            markers: markers,
            polylines: Set<Polyline>.of(polylines.values),
            buildingsEnabled: false,
            myLocationEnabled: true,
            scrollGesturesEnabled: true,
            myLocationButtonEnabled: false,
            zoomGesturesEnabled: true,
            onTap: (LatLng latLng) {
              _solidController.hide();
            },
          ),
          SafeArea(
            child: Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15.0, bottom: 5),
                          padding: const EdgeInsets.all(12.0),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: Colur.txt_white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: Image.asset(
                            'assets/icons/ic_back_white.png',
                            color: Colur.txt_grey,
                            scale: 3.7,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {

                          _showDeleteDialog(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(right: 15.0, bottom: 5),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: Colur.txt_white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset('assets/icons/ic_delete.png'),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ShareScreen(widget.recentActivitiesData)));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(right: 15.0,bottom: 5),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: Colur.txt_white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.share,
                              size: 20,
                              color: Colur.txt_black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    child: Container(
                      height: 44,
                      width: 44,
                      margin: EdgeInsets.only(right: 15.0, top: 5),
                      decoration: BoxDecoration(
                          color: Colur.txt_white,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/ic_setalite.png',
                          color: setaliteEnable
                              ? Colur.purple_gradient_color2
                              : Colur.txt_grey,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        setaliteEnable = !setaliteEnable;
                      });
                      Debug.printLog(
                          (setaliteEnable == true) ? "Started" : "Disabled");
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: _bottomSheetDialog(context),
          ),
        ],
      ),
    );
  }

  _showDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Languages.of(context)!.txtDeleteHitory),
          content: Text(Languages.of(context)!.txtDeleteConfirmationMessage,maxLines: 2,),
          actions: [
            TextButton(
              child: Text(Languages.of(context)!.txtCancel),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(Languages.of(context)!.txtDelete.toUpperCase()),
              onPressed: () async {
                await DataBaseHelper.deleteRunningData(
                        widget.recentActivitiesData)
                    .then((value) => Navigator.of(context)
                        .pushNamedAndRemoveUntil('/homeWizardScreen',
                            (Route<dynamic> route) => false));
              },
            ),
          ],
        );
      },
    );
  }

  _bottomSheetDialog(BuildContext context) {
    return SolidBottomSheet(
        controller: _solidController,
        draggableBody: true,
        canUserSwipe: true,
        toggleVisibilityOnTap: true,
        maxHeight: MediaQuery.of(context).size.height * 0.30,
        headerBar: Container(
          padding: EdgeInsets.only(top: 20.0, right: 25.0, left: 25.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colur.common_bg_dark,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                height: 8,
                width: 40,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colur.txt_grey,
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 25, bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: AutoSizeText(
                              Utils.secToString(
                                  widget.recentActivitiesData.duration!),
                              maxLines: 1,
                              style: TextStyle(
                                  color: Colur.txt_white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              Languages.of(context)!.txtTime.toUpperCase() +
                                  " (${Languages.of(context)!.txtMin.toUpperCase()})",
                              style: TextStyle(
                                  color: Colur.txt_grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              (kmSelected)
                                  ? widget.recentActivitiesData.speed.toString()
                                  : Utils.minPerKmToMinPerMile(
                                          widget.recentActivitiesData.speed!)
                                      .toStringAsFixed(2),
                              style: TextStyle(
                                  color: Colur.txt_white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              (kmSelected)
                                  ? Languages.of(context)!
                                          .txtPaceMinPer
                                          .toUpperCase() +
                                      Languages.of(context)!
                                          .txtKM
                                          .toUpperCase() +
                                      ")"
                                  : Languages.of(context)!
                                          .txtPaceMinPer
                                          .toUpperCase() +
                                      Languages.of(context)!
                                          .txtMile
                                          .toUpperCase() +
                                      ")",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colur.txt_grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              widget.recentActivitiesData.cal.toString(),
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
                                  color: Colur.txt_grey,
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
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 10),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            color: Colur.common_bg_dark,
            child: Column(
              children: [
                Container(
                  child: Text(
                   (kmSelected)?widget.recentActivitiesData.distance!.toStringAsFixed(2):Utils.kmToMile(widget.recentActivitiesData.distance!).toStringAsFixed(2),
                    style: TextStyle(
                        color: Colur.txt_white,
                        fontWeight: FontWeight.w600,
                        fontSize: 60),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 2, bottom: 7),
                  child: Text(
                    Languages.of(context)!.txtDistance+" ("+((kmSelected)?Languages.of(context)!.txtKM:Languages.of(context)!.txtMile)+")",
                    style: TextStyle(
                        color: Colur.txt_grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20,right: 20,bottom: 20),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Languages.of(context)!.txtIntensity +
                              "(" +
                              Languages.of(context)!.txtMin.toUpperCase() +
                              ")" +
                              ":",
                          style: TextStyle(
                              color: Colur.txt_white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 28,
                                    width: 28,
                                    child: Center(
                                        child: Image.asset(
                                      'assets/icons/low_intensity_icon.png',
                                    )),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text(
                                      (widget.recentActivitiesData
                                                  .lowIntenseTime !=
                                              null)
                                          ? Utils.secToString(widget
                                              .recentActivitiesData
                                              .lowIntenseTime!)
                                          : "0:0",
                                      style: TextStyle(
                                          color: Colur.txt_white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    Languages.of(context)!.txtLow.toUpperCase(),
                                    style: TextStyle(
                                        color: Colur.txt_grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  height: 28,
                                  width: 28,
                                  child: Image.asset(
                                    'assets/icons/modrate_intensity_icon.png',
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text(
                                    (widget.recentActivitiesData
                                                .moderateIntenseTime !=
                                            null)
                                        ? Utils.secToString(widget
                                            .recentActivitiesData
                                            .moderateIntenseTime!)
                                        : "0:0",
                                    style: TextStyle(
                                        color: Colur.txt_white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  Languages.of(context)!
                                      .txtModerate
                                      .toUpperCase(),
                                  style: TextStyle(
                                      color: Colur.txt_grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Column(
                                children: [
                                  Container(
                                    height: 28,
                                    width: 28,
                                    child: Image.asset(
                                      'assets/icons/high_intensity_icon.png',
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text(
                                      (widget.recentActivitiesData
                                                  .highIntenseTime !=
                                              null)
                                          ? Utils.secToString(widget
                                              .recentActivitiesData
                                              .highIntenseTime!)
                                          : "0:0",
                                      style: TextStyle(
                                          color: Colur.txt_white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    Languages.of(context)!
                                        .txtHigh
                                        .toUpperCase(),
                                    style: TextStyle(
                                        color: Colur.txt_grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
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
        )
    );
  }
}
