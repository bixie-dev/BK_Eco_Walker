import 'package:floor/floor.dart';
import 'package:run_tracker/dbhelper/datamodel/WeightData.dart';

@dao
abstract class WeightDao {
  @Query('SELECT * FROM weight_table')
  Future<List<WeightData>> selectAllWeight();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertWeight(WeightData task);

  @Query('SELECT AVG(weight_kg) as average FROM (SELECT * FROM weight_table ORDER BY id DESC LIMIT 30)')
  Future<WeightData?> selectLast30DaysWeightAverage();
}