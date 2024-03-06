import 'dart:convert';
import 'dart:io';

import 'package:floor/floor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@entity
class RunningData {
  @PrimaryKey(autoGenerate: true)
  int? id;

  int? duration;
  double? distance;
  double? speed;
  double? cal;
  String? sLat;
  String? sLong;
  String? eLat;
  String? eLong;
  String? image;
  String? polyLine;
  String? date;
  int? lowIntenseTime;
  int? moderateIntenseTime;
  int? highIntenseTime;
  double? total;
  int? allTotal;

  @ignore
  File? imageFile;

  RunningData(
      {this.id,
      this.duration,
      this.distance,
      this.speed,
      this.cal,
      this.sLat,
      this.eLong,
      this.eLat,
      this.sLong,
      this.image,
      this.polyLine,
      this.date,
      this.lowIntenseTime,
      this.moderateIntenseTime,
      this.highIntenseTime,
      this.total,this.allTotal = 0});

  File? getImage() {
    File? file;
    if (image != null) {
      file = File(image!);
    }

    return file;
  }

  List<LatLng>? getPolyLineData() {
    List<LatLng> polylineData = [];

    List<dynamic> list = jsonDecode(polyLine!);

    list.forEach((element) {
      var lat = double.parse((element)[0].toString());
      var long = double.parse((element)[1].toString());

      polylineData.add(LatLng(lat, long));
    });

    return polylineData;
  }
}
