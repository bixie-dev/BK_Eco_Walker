import 'package:run_tracker/dbhelper/database.dart';
import 'package:run_tracker/dbhelper/datamodel/RunningData.dart';
import 'package:run_tracker/dbhelper/datamodel/StepsData.dart';
import 'package:run_tracker/dbhelper/datamodel/WaterData.dart';
import 'package:run_tracker/dbhelper/datamodel/WeightData.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';

class DataBaseHelper {
  static final DataBaseHelper _dataBaseHelper = DataBaseHelper._internal();

  factory DataBaseHelper() {
    return _dataBaseHelper;
  }

  DataBaseHelper._internal();

  static FlutterDatabase? _database;

  Future<FlutterDatabase?> initialize() async {
    _database =
        await $FloorFlutterDatabase.databaseBuilder('running_app.db').build();
    return _database;
  }


  Future<WaterData> insertDrinkWater(WaterData data) async {
    final waterDao = _database!.waterDao;
    await waterDao.insertDrinkWater(data);
    Debug.printLog("Insert DrinkWater Data Successfully  ==> " +
        data.ml.toString() +
        " CurrentTime ==> " +
        data.dateTime.toString() +
        " Date ==> " +
        data.date.toString() +
        " Time ==> " +
        data.time.toString());
    return data;
  }

  Future<List<WaterData>> selectTodayDrinkWater(String date) async {
    final waterDao = _database!.waterDao;
    final List<WaterData> result = await waterDao.getTodayDrinkWater(date);
    result.forEach((element) {
      Debug.printLog("Select Today DrinkWater Data Successfully  ==> Id =>" +
          element.id.toString() +
          " Ml =>" +
          element.ml.toString() +
          " Date ==> " +
          element.date.toString() +
          " Time ==> " +
          element.time.toString() +
          " DateTime => " +
          element.dateTime.toString());
    });
    return result;
  }

  static Future<int?> getTotalDrinkWater(String date) async {
    final waterDao = _database!.waterDao;
    final totalDrinkWater = await waterDao.getTotalOfDrinkWater(date);
    Debug.printLog("Total DrinkWater ==> " + totalDrinkWater!.total.toString());
    return totalDrinkWater.total;
  }

  static Future<List<WaterData>> getTotalDrinkWaterAllDays(
      List<String> date) async {
    final waterDao = _database!.waterDao;
    final totalDrinkWater = await waterDao.getTotalDrinkWaterAllDays(date);
    totalDrinkWater.forEach((element) {
      Debug.printLog("Total DrinkWater For Week Days ==> " +
          element.total.toString() +
          " Date ==> " +
          element.date.toString());
    });
    return totalDrinkWater;
  }

  static Future<int?> getTotalDrinkWaterAverage(List<String> date) async {
    final waterDao = _database!.waterDao;
    final totalDrinkWater = await waterDao.getTotalDrinkWaterAverage(date);
    Debug.printLog(
        "Daily Average DrinkWater ==> " + totalDrinkWater!.total.toString());
    return totalDrinkWater.total;
  }

  static Future<WaterData> deleteTodayDrinkWater(WaterData data) async {
    final waterDao = _database!.waterDao;
    await waterDao.deleteTodayDrinkWater(data);
    Debug.printLog(
        "Delete DrinkWater From Today History==> " + data.toString());
    return data;
  }


  static Future<WeightData> insertWeight(WeightData data) async {
    final weightDao = _database!.weightDao;
    await weightDao.insertWeight(data);
    Debug.printLog("Insert Weight Data Successfully  ==> " +
        " Id ==> " +
        data.id.toString() +
        " Weight Kg ==> " +
        data.weightKg.toString() +
        " Weight Lbs ==> " +
        data.weightLbs.toString() +
        " Date ==> " +
        data.date.toString());
    return data;
  }

  static Future<List<WeightData>> selectWeight() async {
    final weightDao = _database!.weightDao;
    final List<WeightData> result = await weightDao.selectAllWeight();
    result.forEach((element) {
      Debug.printLog("Select Weight Data Successfully  ==>" +
          " Id ==> " +
          element.id.toString() +
          " Weight Kg ==> " +
          element.weightKg.toString() +
          " Weight Lbs ==> " +
          element.weightLbs.toString() +
          " Date ==> " +
          element.date.toString());
    });
    return result;
  }

  static Future<double?> getLast30DaysWeightAverage() async {
    final weightDao = _database!.weightDao;
    final avgWeight = await weightDao.selectLast30DaysWeightAverage();
    Debug.printLog("Last 30 Days Average of Weight ==> " + avgWeight!.average.toString());
    return avgWeight.average;
  }


  static Future<List<RunningData>> selectMapHistory() async {
    final runningDao = _database!.runningDao;
    final result = await runningDao.getAllHistory();
    result.forEach((element) {
      Debug.printLog("Health For Week Days ==> id :==" +
          element.id.toString() +
          " allTotal :==" +
          element.allTotal.toString() +
          " total :==" +
          element.total.toString() +
          " date :==" +
          element.date.toString() +
          " cal :==" +
          element.cal.toString() +
          " distance :==" +
          element.distance.toString() +
          " duration :==" +
          element.duration.toString() +
          " highIntenseTime :==" +
          element.highIntenseTime.toString() +
          " lowIntenseTime :==" +
          element.lowIntenseTime.toString() +
          " moderateIntenseTime :==" +
          element.moderateIntenseTime.toString()+
          " speed :==" +
          element.speed.toString());
    });
    return result;
  }

  Future<List<RunningData>> getRecentTasksAsStream() async {
    final runningDao = _database!.runningDao;
    final result = await runningDao.findRecentTasksAsStream();
    return result;
  }

  static Future<int> insertRunningData(RunningData data) async {
    final runningDao = _database!.runningDao;
    int id = await runningDao.insertTask(data);
    Debug.printLog("insertRunningData Data Successfully  ==> " + id.toString());
    return id;
  }

  static Future<void> deleteRunningData(RunningData data) async {
    final runningDao = _database!.runningDao;
    await runningDao.deleteTask(data);
    Debug.printLog("Delete RunningData History==> " + data.toString());
  }

  static Future<RunningData?> getMaxDistance() async {
    final runningDao = _database!.runningDao;
    final maxDistance = await runningDao.findLongestDistance();
    return maxDistance!;
  }
  static Future<RunningData?> getSumOfTotalDistance() async {
    final runningDao = _database!.runningDao;
    final sumofDistance = await runningDao.findSumOfDistance();
    return sumofDistance!;
  }

  static Future<RunningData?> getMaxPace() async {
    final runningDao = _database!.runningDao;
    final maxPace = await runningDao.findBestPace();
    return maxPace!;
  }

  static Future<RunningData?> getLongestDuration() async {
    final runningDao = _database!.runningDao;
    final longestDuration = await runningDao.findMaxDuration();
    return longestDuration!;
  }

  static Future<RunningData?> getSumOfTotalCalories() async {
    final runningDao = _database!.runningDao;
    final sumofCalories = await runningDao.findSumOfCalories();
    return sumofCalories!;
  }

  static Future<RunningData?> getAverageOfSpeed() async {
    final runningDao = _database!.runningDao;
    final avgOfSpeed = await runningDao.findAverageOfSpeed();
    return avgOfSpeed!;
  }

  static Future<RunningData?> getSumOfTotalDuration() async {
    final runningDao = _database!.runningDao;
    final sumofDuration = await runningDao.findSumOfDuration();
    return sumofDuration!;
  }

  static Future<int?> getSumOfTotalHighIntensity(List<String> date) async{
    final runningDao = _database!.runningDao;
    final sumofHighIntensity = await runningDao.getTotalOfHighIntensity(date);
    return sumofHighIntensity!.highIntenseTime;
  }

  static Future<int?> getSumOfTotalLowIntensity(List<String> date) async{
    final runningDao = _database!.runningDao;
    final sumofLowIntensity = await runningDao.getTotalOfLowIntensity(date);
    return sumofLowIntensity!.lowIntenseTime;
  }

  static Future<int?> getSumOfTotalModerateIntensity(List<String> date) async{
    final runningDao = _database!.runningDao;
    final sumofModerateIntensity = await runningDao.getTotalOfModerateIntensity(date);
    return sumofModerateIntensity!.moderateIntenseTime;
  }

  static Future<List<RunningData>> getHeartHealth(
      List<String> date) async {
    final runningDao = _database!.runningDao;
    final heartHealth = await runningDao.getHeartHealth(date);
    await DataBaseHelper.selectMapHistory();
    heartHealth.forEach((element) {
      Debug.printLog("Health For Week Days ==> allTotal ==>" +
          element.allTotal.toString());
    });
    return heartHealth;
  }


  Future<StepsData> insertSteps(StepsData data) async {
    final stepsDao = _database!.stepsDao;
    await stepsDao.insertAllStepsData(data);
    Debug.printLog("Insert Steps Data Successfully  ==> " +
        " Steps ==> " +
        data.steps.toString() +
        " Target Steps ==> " +
        data.targetSteps.toString() +
        " Calories ==> " +
        data.cal.toString() +
        " Distance ==> " +
        data.distance.toString() +
        " Duration ==> " +
        data.duration.toString() +
        " CurrentTime ==> " +
        data.dateTime.toString() +
        " Date ==> " +
        data.stepDate.toString() +
        " Time ==> " +
        data.time.toString());
    return data;
  }

  Future<List<StepsData>> getAllStepsData() async {
    final stepsDao = _database!.stepsDao;
    final List<StepsData> result = await stepsDao.getAllStepsData();
    result.forEach((element) {
      Debug.printLog("Select Steps Data Successfully  ==> Id=>" +
          element.id.toString() +
          " Steps=>" +
          element.steps.toString() +
          " Target Steps=>" +
          element.targetSteps.toString() +
          " Date=>" +
          element.stepDate.toString() +
          " Time=>" +
          element.time.toString() +
          " DateTime=>" +
          element.dateTime.toString() +
          " Kcal=>" +
          element.cal.toString() +
          " Duration=>" +
          element.duration.toString() +
          " Distance=>" +
          element.distance.toString());
    });
    return result;
  }

  Future<List<StepsData>> getStepsForCurrentWeek() async {
    final stepsDao = _database!.stepsDao;
    var prefDay = Preference.shared.getInt(Preference.FIRST_DAY_OF_WEEK_IN_NUM) ?? 1;
    List<StepsData>? steps;

    if(prefDay == 0){
      steps =  await stepsDao.getStepsForCurrentWeekSun();
    }else if(prefDay == 1){
      steps =  await stepsDao.getStepsForCurrentWeekMon();
    }else if(prefDay == -1){
      steps =  await stepsDao.getStepsForCurrentWeekSat();
    }

    steps!.forEach((element) {
      Debug.printLog("-----------Steps For Week Days ==> " +
          " Steps ==> " + element.steps.toString() + " Date ==> " +
          element.stepDate.toString() + "------------");
    });
    return steps;
  }

  Future<int?> getTotalStepsForLast7Days() async {
    final stepsDao = _database!.stepsDao;
    final totalSteps = await stepsDao.getTotalStepsForLast7Days();
    Debug.printLog("Steps from last 7 days =====> ${totalSteps!.steps}");
    return totalSteps.steps;
  }

  Future<List<StepsData>> getStepsForCurrentMonth() async {
    final stepsDao = _database!.stepsDao;
    final steps = await stepsDao.getStepsForCurrentMonth();
    steps.forEach((element) {
      Debug.printLog("-----------Steps For Month Days ==> " +
          " Steps ==> " + element.steps.toString() + " Date ==> " +
          element.stepDate.toString() + "------------");
    });
    return steps;
  }

  Future<int?> getTotalStepsForCurrentMonth() async {
    final stepsDao = _database!.stepsDao;
    final totalSteps = await stepsDao.getTotalStepsForCurrentMonth();
    Debug.printLog("Total Steps from current month =====> ${totalSteps!.steps}");
    return totalSteps.steps;
  }

  Future<int?> getTotalStepsForCurrentWeek() async {
    final stepsDao = _database!.stepsDao;
    final totalSteps = await stepsDao.getTotalStepsForCurrentWeek();
    Debug.printLog("Total Steps from current week =====> ${totalSteps!.steps}");
    return totalSteps.steps;
  }

  Future<List<StepsData>> getLast7DaysStepsData() async {
    final stepsDao = _database!.stepsDao;
    final List<StepsData> result = await stepsDao.getLast7DaysStepsData();
    result.forEach((element) {
      Debug.printLog("Select Steps Data Successfully  ==> Id=>" +
          element.id.toString() +
          " Steps=>" +
          element.steps.toString() +
          " Target Steps=>" +
          element.targetSteps.toString() +
          " Date=>" +
          element.stepDate.toString() +
          " Time=>" +
          element.time.toString() +
          " DateTime=>" +
          element.dateTime.toString() +
          " Kcal=>" +
          element.cal.toString() +
          " Duration=>" +
          element.duration.toString() +
          " Distance=>" +
          element.distance.toString());
    });
    return result;
  }
}
