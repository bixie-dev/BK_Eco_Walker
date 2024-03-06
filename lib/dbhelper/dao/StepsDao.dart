import 'package:floor/floor.dart';
import 'package:run_tracker/dbhelper/datamodel/StepsData.dart';

@dao
abstract class StepsDao {
  @insert
  Future<void> insertAllStepsData(StepsData stepsData);

  @Query('SELECT * FROM steps_table')
  Future<List<StepsData>> getAllStepsData();

  @Query('SELECT * FROM steps_table WHERE (DATE(stepDate) >= DATE("now","weekday 0","-7 days"))')
  Future<List<StepsData>> getStepsForCurrentWeekSun();

  @Query('SELECT * FROM steps_table WHERE (DATE(stepDate) >= DATE("now","weekday 6","-7 days"))')
  Future<List<StepsData>> getStepsForCurrentWeekSat();

  @Query('SELECT * FROM steps_table WHERE (DATE(stepDate) >= DATE("now","weekday 1","-7 days"))')
  Future<List<StepsData>> getStepsForCurrentWeekMon();

  @Query('SELECT IFNULL(SUM(steps),0) as steps FROM steps_table WHERE DATE(stepDate) >= (SELECT DATE("now","-7 days"))')
  Future<StepsData?> getTotalStepsForLast7Days();

  @Query('SELECT * FROM steps_table WHERE (DATE(stepDate) >= DATE("now","start of month"))')
  Future<List<StepsData>> getStepsForCurrentMonth();

  @Query('SELECT IFNULL(SUM(steps),0) as steps FROM steps_table WHERE (DATE(stepDate) >= DATE("now","start of month"))')
  Future<StepsData?> getTotalStepsForCurrentMonth();

  @Query('SELECT IFNULL(SUM(steps),0) as steps FROM steps_table WHERE (DATE(stepDate) >= DATE("now","weekday 1","-7 days"))')
  Future<StepsData?> getTotalStepsForCurrentWeek();

  @Query('SELECT * FROM steps_table WHERE (DATE(stepDate) >= DATE("now","-7 days"))')
  Future<List<StepsData>> getLast7DaysStepsData();
  


}