import 'dart:async';

import 'package:floor/floor.dart';
import 'package:run_tracker/dbhelper/dao/RunningDao.dart';
import 'package:run_tracker/dbhelper/dao/StepsDao.dart';
import 'package:run_tracker/dbhelper/dao/WaterDao.dart';
import 'package:run_tracker/dbhelper/dao/WeightDao.dart';
import 'package:run_tracker/dbhelper/datamodel/RunningData.dart';
import 'package:run_tracker/dbhelper/datamodel/StepsData.dart';
import 'package:run_tracker/dbhelper/datamodel/WaterData.dart';
import 'package:run_tracker/dbhelper/datamodel/WeightData.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@Database(version: 1, entities: [RunningData , WaterData, WeightData, StepsData])
abstract class FlutterDatabase extends FloorDatabase {
  RunningDao get runningDao;

  WaterDao get waterDao;

  WeightDao get weightDao;

  StepsDao get stepsDao;
}
