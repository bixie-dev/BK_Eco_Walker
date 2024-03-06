import 'package:floor/floor.dart';
import 'package:run_tracker/dbhelper/datamodel/RunningData.dart';

@dao
abstract class RunningDao {
  @Query('SELECT * FROM RunningData')
  Future<List<RunningData>> getAllHistory();

  @Query('SELECT * FROM RunningData ORDER BY id DESC LIMIT 3')
  Future<List<RunningData>> findRecentTasksAsStream();

  @Query('SELECT *,IFNULL(MAX(distance),0) FROM RunningData')
  Future<RunningData?> findLongestDistance();

  @Query('SELECT IFNULL(SUM(distance),0.0) as total FROM RunningData')
  Future<RunningData?> findSumOfDistance();

  @Query('SELECT *,IFNULL(MIN(speed),0) FROM RunningData')
  Future<RunningData?> findBestPace();

  @Query('SELECT *,IFNULL(MAX(duration),0) FROM RunningData')
  Future<RunningData?> findMaxDuration();

  @Query('SELECT IFNULL(SUM(cal),0.0) as total FROM RunningData')
  Future<RunningData?> findSumOfCalories();

  @Query('SELECT IFNULL(AVG(speed),0.0) as total FROM RunningData')
  Future<RunningData?> findAverageOfSpeed();

  @Query('SELECT IFNULL(SUM(duration),0) as duration FROM RunningData')
  Future<RunningData?> findSumOfDuration();

  @Query('SELECT IFNULL(SUM(highIntenseTime),0) as highIntenseTime FROM RunningData WHERE date IN(:date)')
  Future<RunningData?> getTotalOfHighIntensity(List<String> date);

  @Query('SELECT IFNULL(SUM(lowIntenseTime),0) as lowIntenseTime FROM RunningData WHERE date IN(:date)')
  Future<RunningData?> getTotalOfLowIntensity(List<String> date);

  @Query('SELECT IFNULL(SUM(moderateIntenseTime),0) as moderateIntenseTime FROM RunningData WHERE date IN(:date)')
  Future<RunningData?> getTotalOfModerateIntensity(List<String> date);

  @Query('SELECT *, (SELECT IFNULL(SUM(lowIntenseTime + moderateIntenseTime),0) FROM RunningData WHERE date = wt2.date) as allTotal FROM RunningData as wt2 WHERE date IN(:date) GROUP BY date')
  Future<List<RunningData>> getHeartHealth(List<String> date);

  @insert
  Future<int> insertTask(RunningData task);

  @delete
  Future<void> deleteTask(RunningData task);

}