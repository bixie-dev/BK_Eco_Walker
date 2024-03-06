// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorFlutterDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDatabaseBuilder databaseBuilder(String name) =>
      _$FlutterDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$FlutterDatabaseBuilder(null);
}

class _$FlutterDatabaseBuilder {
  _$FlutterDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$FlutterDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$FlutterDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<FlutterDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$FlutterDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$FlutterDatabase extends FlutterDatabase {
  _$FlutterDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RunningDao? _runningDaoInstance;

  WaterDao? _waterDaoInstance;

  WeightDao? _weightDaoInstance;

  StepsDao? _stepsDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RunningData` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `duration` INTEGER, `distance` REAL, `speed` REAL, `cal` REAL, `sLat` TEXT, `sLong` TEXT, `eLat` TEXT, `eLong` TEXT, `image` TEXT, `polyLine` TEXT, `date` TEXT, `lowIntenseTime` INTEGER, `moderateIntenseTime` INTEGER, `highIntenseTime` INTEGER, `total` REAL, `allTotal` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `water_table` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `ml` INTEGER, `date` TEXT, `time` TEXT, `date_time` TEXT, `total` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `weight_table` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `weight_kg` REAL, `weight_lbs` REAL, `date` TEXT, `average` REAL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `steps_table` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `steps` INTEGER, `targetSteps` INTEGER, `stepDate` TEXT, `time` TEXT, `date_time` TEXT, `duration` TEXT, `cal` INTEGER, `distance` REAL)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_weight_table_date` ON `weight_table` (`date`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  RunningDao get runningDao {
    return _runningDaoInstance ??= _$RunningDao(database, changeListener);
  }

  @override
  WaterDao get waterDao {
    return _waterDaoInstance ??= _$WaterDao(database, changeListener);
  }

  @override
  WeightDao get weightDao {
    return _weightDaoInstance ??= _$WeightDao(database, changeListener);
  }

  @override
  StepsDao get stepsDao {
    return _stepsDaoInstance ??= _$StepsDao(database, changeListener);
  }
}

class _$RunningDao extends RunningDao {
  _$RunningDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _runningDataInsertionAdapter = InsertionAdapter(
            database,
            'RunningData',
            (RunningData item) => <String, Object?>{
                  'id': item.id,
                  'duration': item.duration,
                  'distance': item.distance,
                  'speed': item.speed,
                  'cal': item.cal,
                  'sLat': item.sLat,
                  'sLong': item.sLong,
                  'eLat': item.eLat,
                  'eLong': item.eLong,
                  'image': item.image,
                  'polyLine': item.polyLine,
                  'date': item.date,
                  'lowIntenseTime': item.lowIntenseTime,
                  'moderateIntenseTime': item.moderateIntenseTime,
                  'highIntenseTime': item.highIntenseTime,
                  'total': item.total,
                  'allTotal': item.allTotal
                }),
        _runningDataDeletionAdapter = DeletionAdapter(
            database,
            'RunningData',
            ['id'],
            (RunningData item) => <String, Object?>{
                  'id': item.id,
                  'duration': item.duration,
                  'distance': item.distance,
                  'speed': item.speed,
                  'cal': item.cal,
                  'sLat': item.sLat,
                  'sLong': item.sLong,
                  'eLat': item.eLat,
                  'eLong': item.eLong,
                  'image': item.image,
                  'polyLine': item.polyLine,
                  'date': item.date,
                  'lowIntenseTime': item.lowIntenseTime,
                  'moderateIntenseTime': item.moderateIntenseTime,
                  'highIntenseTime': item.highIntenseTime,
                  'total': item.total,
                  'allTotal': item.allTotal
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<RunningData> _runningDataInsertionAdapter;

  final DeletionAdapter<RunningData> _runningDataDeletionAdapter;

  @override
  Future<List<RunningData>> getAllHistory() async {
    return _queryAdapter.queryList('SELECT * FROM RunningData',
        mapper: (Map<String, Object?> row) => RunningData(
            id: row['id'] as int?,
            duration: row['duration'] as int?,
            distance: row['distance'] as double?,
            speed: row['speed'] as double?,
            cal: row['cal'] as double?,
            sLat: row['sLat'] as String?,
            eLong: row['eLong'] as String?,
            eLat: row['eLat'] as String?,
            sLong: row['sLong'] as String?,
            image: row['image'] as String?,
            polyLine: row['polyLine'] as String?,
            date: row['date'] as String?,
            lowIntenseTime: row['lowIntenseTime'] as int?,
            moderateIntenseTime: row['moderateIntenseTime'] as int?,
            highIntenseTime: row['highIntenseTime'] as int?,
            total: row['total'] as double?,
            allTotal: row['allTotal'] as int?));
  }

  @override
  Future<List<RunningData>> findRecentTasksAsStream() async {
    return _queryAdapter.queryList(
        'SELECT * FROM RunningData ORDER BY id DESC LIMIT 3',
        mapper: (Map<String, Object?> row) => RunningData(
            id: row['id'] as int?,
            duration: row['duration'] as int?,
            distance: row['distance'] as double?,
            speed: row['speed'] as double?,
            cal: row['cal'] as double?,
            sLat: row['sLat'] as String?,
            eLong: row['eLong'] as String?,
            eLat: row['eLat'] as String?,
            sLong: row['sLong'] as String?,
            image: row['image'] as String?,
            polyLine: row['polyLine'] as String?,
            date: row['date'] as String?,
            lowIntenseTime: row['lowIntenseTime'] as int?,
            moderateIntenseTime: row['moderateIntenseTime'] as int?,
            highIntenseTime: row['highIntenseTime'] as int?,
            total: row['total'] as double?,
            allTotal: row['allTotal'] as int?));
  }

  @override
  Future<RunningData?> findLongestDistance() async {
    return _queryAdapter.query(
        'SELECT *,IFNULL(MAX(distance),0) FROM RunningData',
        mapper: (Map<String, Object?> row) => RunningData(
            id: row['id'] as int?,
            duration: row['duration'] as int?,
            distance: row['distance'] as double?,
            speed: row['speed'] as double?,
            cal: row['cal'] as double?,
            sLat: row['sLat'] as String?,
            eLong: row['eLong'] as String?,
            eLat: row['eLat'] as String?,
            sLong: row['sLong'] as String?,
            image: row['image'] as String?,
            polyLine: row['polyLine'] as String?,
            date: row['date'] as String?,
            lowIntenseTime: row['lowIntenseTime'] as int?,
            moderateIntenseTime: row['moderateIntenseTime'] as int?,
            highIntenseTime: row['highIntenseTime'] as int?,
            total: row['total'] as double?,
            allTotal: row['allTotal'] as int?));
  }

  @override
  Future<RunningData?> findSumOfDistance() async {
    return _queryAdapter.query(
        'SELECT IFNULL(SUM(distance),0.0) as total FROM RunningData',
        mapper: (Map<String, Object?> row) => RunningData(
            id: row['id'] as int?,
            duration: row['duration'] as int?,
            distance: row['distance'] as double?,
            speed: row['speed'] as double?,
            cal: row['cal'] as double?,
            sLat: row['sLat'] as String?,
            eLong: row['eLong'] as String?,
            eLat: row['eLat'] as String?,
            sLong: row['sLong'] as String?,
            image: row['image'] as String?,
            polyLine: row['polyLine'] as String?,
            date: row['date'] as String?,
            lowIntenseTime: row['lowIntenseTime'] as int?,
            moderateIntenseTime: row['moderateIntenseTime'] as int?,
            highIntenseTime: row['highIntenseTime'] as int?,
            total: row['total'] as double?,
            allTotal: row['allTotal'] as int?));
  }

  @override
  Future<RunningData?> findBestPace() async {
    return _queryAdapter.query('SELECT *,IFNULL(MIN(speed),0) FROM RunningData',
        mapper: (Map<String, Object?> row) => RunningData(
            id: row['id'] as int?,
            duration: row['duration'] as int?,
            distance: row['distance'] as double?,
            speed: row['speed'] as double?,
            cal: row['cal'] as double?,
            sLat: row['sLat'] as String?,
            eLong: row['eLong'] as String?,
            eLat: row['eLat'] as String?,
            sLong: row['sLong'] as String?,
            image: row['image'] as String?,
            polyLine: row['polyLine'] as String?,
            date: row['date'] as String?,
            lowIntenseTime: row['lowIntenseTime'] as int?,
            moderateIntenseTime: row['moderateIntenseTime'] as int?,
            highIntenseTime: row['highIntenseTime'] as int?,
            total: row['total'] as double?,
            allTotal: row['allTotal'] as int?));
  }

  @override
  Future<RunningData?> findMaxDuration() async {
    return _queryAdapter.query(
        'SELECT *,IFNULL(MAX(duration),0) FROM RunningData',
        mapper: (Map<String, Object?> row) => RunningData(
            id: row['id'] as int?,
            duration: row['duration'] as int?,
            distance: row['distance'] as double?,
            speed: row['speed'] as double?,
            cal: row['cal'] as double?,
            sLat: row['sLat'] as String?,
            eLong: row['eLong'] as String?,
            eLat: row['eLat'] as String?,
            sLong: row['sLong'] as String?,
            image: row['image'] as String?,
            polyLine: row['polyLine'] as String?,
            date: row['date'] as String?,
            lowIntenseTime: row['lowIntenseTime'] as int?,
            moderateIntenseTime: row['moderateIntenseTime'] as int?,
            highIntenseTime: row['highIntenseTime'] as int?,
            total: row['total'] as double?,
            allTotal: row['allTotal'] as int?));
  }

  @override
  Future<RunningData?> findSumOfCalories() async {
    return _queryAdapter.query(
        'SELECT IFNULL(SUM(cal),0.0) as total FROM RunningData',
        mapper: (Map<String, Object?> row) => RunningData(
            id: row['id'] as int?,
            duration: row['duration'] as int?,
            distance: row['distance'] as double?,
            speed: row['speed'] as double?,
            cal: row['cal'] as double?,
            sLat: row['sLat'] as String?,
            eLong: row['eLong'] as String?,
            eLat: row['eLat'] as String?,
            sLong: row['sLong'] as String?,
            image: row['image'] as String?,
            polyLine: row['polyLine'] as String?,
            date: row['date'] as String?,
            lowIntenseTime: row['lowIntenseTime'] as int?,
            moderateIntenseTime: row['moderateIntenseTime'] as int?,
            highIntenseTime: row['highIntenseTime'] as int?,
            total: row['total'] as double?,
            allTotal: row['allTotal'] as int?));
  }

  @override
  Future<RunningData?> findAverageOfSpeed() async {
    return _queryAdapter.query(
        'SELECT IFNULL(AVG(speed),0.0) as total FROM RunningData',
        mapper: (Map<String, Object?> row) => RunningData(
            id: row['id'] as int?,
            duration: row['duration'] as int?,
            distance: row['distance'] as double?,
            speed: row['speed'] as double?,
            cal: row['cal'] as double?,
            sLat: row['sLat'] as String?,
            eLong: row['eLong'] as String?,
            eLat: row['eLat'] as String?,
            sLong: row['sLong'] as String?,
            image: row['image'] as String?,
            polyLine: row['polyLine'] as String?,
            date: row['date'] as String?,
            lowIntenseTime: row['lowIntenseTime'] as int?,
            moderateIntenseTime: row['moderateIntenseTime'] as int?,
            highIntenseTime: row['highIntenseTime'] as int?,
            total: row['total'] as double?,
            allTotal: row['allTotal'] as int?));
  }

  @override
  Future<RunningData?> findSumOfDuration() async {
    return _queryAdapter.query(
        'SELECT IFNULL(SUM(duration),0) as duration FROM RunningData',
        mapper: (Map<String, Object?> row) => RunningData(
            id: row['id'] as int?,
            duration: row['duration'] as int?,
            distance: row['distance'] as double?,
            speed: row['speed'] as double?,
            cal: row['cal'] as double?,
            sLat: row['sLat'] as String?,
            eLong: row['eLong'] as String?,
            eLat: row['eLat'] as String?,
            sLong: row['sLong'] as String?,
            image: row['image'] as String?,
            polyLine: row['polyLine'] as String?,
            date: row['date'] as String?,
            lowIntenseTime: row['lowIntenseTime'] as int?,
            moderateIntenseTime: row['moderateIntenseTime'] as int?,
            highIntenseTime: row['highIntenseTime'] as int?,
            total: row['total'] as double?,
            allTotal: row['allTotal'] as int?));
  }

  @override
  Future<RunningData?> getTotalOfHighIntensity(List<String> date) async {
    const offset = 1;
    final _sqliteVariablesForDate =
        Iterable<String>.generate(date.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.query(
        'SELECT IFNULL(SUM(highIntenseTime),0) as highIntenseTime FROM RunningData WHERE date IN(' +
            _sqliteVariablesForDate +
            ')',
        mapper: (Map<String, Object?> row) => RunningData(id: row['id'] as int?, duration: row['duration'] as int?, distance: row['distance'] as double?, speed: row['speed'] as double?, cal: row['cal'] as double?, sLat: row['sLat'] as String?, eLong: row['eLong'] as String?, eLat: row['eLat'] as String?, sLong: row['sLong'] as String?, image: row['image'] as String?, polyLine: row['polyLine'] as String?, date: row['date'] as String?, lowIntenseTime: row['lowIntenseTime'] as int?, moderateIntenseTime: row['moderateIntenseTime'] as int?, highIntenseTime: row['highIntenseTime'] as int?, total: row['total'] as double?, allTotal: row['allTotal'] as int?),
        arguments: [...date]);
  }

  @override
  Future<RunningData?> getTotalOfLowIntensity(List<String> date) async {
    const offset = 1;
    final _sqliteVariablesForDate =
        Iterable<String>.generate(date.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.query(
        'SELECT IFNULL(SUM(lowIntenseTime),0) as lowIntenseTime FROM RunningData WHERE date IN(' +
            _sqliteVariablesForDate +
            ')',
        mapper: (Map<String, Object?> row) => RunningData(id: row['id'] as int?, duration: row['duration'] as int?, distance: row['distance'] as double?, speed: row['speed'] as double?, cal: row['cal'] as double?, sLat: row['sLat'] as String?, eLong: row['eLong'] as String?, eLat: row['eLat'] as String?, sLong: row['sLong'] as String?, image: row['image'] as String?, polyLine: row['polyLine'] as String?, date: row['date'] as String?, lowIntenseTime: row['lowIntenseTime'] as int?, moderateIntenseTime: row['moderateIntenseTime'] as int?, highIntenseTime: row['highIntenseTime'] as int?, total: row['total'] as double?, allTotal: row['allTotal'] as int?),
        arguments: [...date]);
  }

  @override
  Future<RunningData?> getTotalOfModerateIntensity(List<String> date) async {
    const offset = 1;
    final _sqliteVariablesForDate =
        Iterable<String>.generate(date.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.query(
        'SELECT IFNULL(SUM(moderateIntenseTime),0) as moderateIntenseTime FROM RunningData WHERE date IN(' +
            _sqliteVariablesForDate +
            ')',
        mapper: (Map<String, Object?> row) => RunningData(id: row['id'] as int?, duration: row['duration'] as int?, distance: row['distance'] as double?, speed: row['speed'] as double?, cal: row['cal'] as double?, sLat: row['sLat'] as String?, eLong: row['eLong'] as String?, eLat: row['eLat'] as String?, sLong: row['sLong'] as String?, image: row['image'] as String?, polyLine: row['polyLine'] as String?, date: row['date'] as String?, lowIntenseTime: row['lowIntenseTime'] as int?, moderateIntenseTime: row['moderateIntenseTime'] as int?, highIntenseTime: row['highIntenseTime'] as int?, total: row['total'] as double?, allTotal: row['allTotal'] as int?),
        arguments: [...date]);
  }

  @override
  Future<List<RunningData>> getHeartHealth(List<String> date) async {
    const offset = 1;
    final _sqliteVariablesForDate =
        Iterable<String>.generate(date.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT *, (SELECT IFNULL(SUM(lowIntenseTime + moderateIntenseTime),0) FROM RunningData WHERE date = wt2.date) as allTotal FROM RunningData as wt2 WHERE date IN(' +
            _sqliteVariablesForDate +
            ') GROUP BY date',
        mapper: (Map<String, Object?> row) => RunningData(id: row['id'] as int?, duration: row['duration'] as int?, distance: row['distance'] as double?, speed: row['speed'] as double?, cal: row['cal'] as double?, sLat: row['sLat'] as String?, eLong: row['eLong'] as String?, eLat: row['eLat'] as String?, sLong: row['sLong'] as String?, image: row['image'] as String?, polyLine: row['polyLine'] as String?, date: row['date'] as String?, lowIntenseTime: row['lowIntenseTime'] as int?, moderateIntenseTime: row['moderateIntenseTime'] as int?, highIntenseTime: row['highIntenseTime'] as int?, total: row['total'] as double?, allTotal: row['allTotal'] as int?),
        arguments: [...date]);
  }

  @override
  Future<int> insertTask(RunningData task) {
    return _runningDataInsertionAdapter.insertAndReturnId(
        task, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTask(RunningData task) async {
    await _runningDataDeletionAdapter.delete(task);
  }
}

class _$WaterDao extends WaterDao {
  _$WaterDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _waterDataInsertionAdapter = InsertionAdapter(
            database,
            'water_table',
            (WaterData item) => <String, Object?>{
                  'id': item.id,
                  'ml': item.ml,
                  'date': item.date,
                  'time': item.time,
                  'date_time': item.dateTime,
                  'total': item.total
                }),
        _waterDataDeletionAdapter = DeletionAdapter(
            database,
            'water_table',
            ['id'],
            (WaterData item) => <String, Object?>{
                  'id': item.id,
                  'ml': item.ml,
                  'date': item.date,
                  'time': item.time,
                  'date_time': item.dateTime,
                  'total': item.total
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WaterData> _waterDataInsertionAdapter;

  final DeletionAdapter<WaterData> _waterDataDeletionAdapter;

  @override
  Future<List<WaterData>> getTodayDrinkWater(String date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM water_table WHERE date = ?1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => WaterData(
            id: row['id'] as int?,
            ml: row['ml'] as int?,
            date: row['date'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            total: row['total'] as int?),
        arguments: [date]);
  }

  @override
  Future<WaterData?> getTotalOfDrinkWater(String date) async {
    return _queryAdapter.query(
        'SELECT IFNULL(SUM(ml),0) as total FROM water_table WHERE date = ?1',
        mapper: (Map<String, Object?> row) => WaterData(
            id: row['id'] as int?,
            ml: row['ml'] as int?,
            date: row['date'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            total: row['total'] as int?),
        arguments: [date]);
  }

  @override
  Future<List<WaterData>> getTotalDrinkWaterAllDays(List<String> date) async {
    const offset = 1;
    final _sqliteVariablesForDate =
        Iterable<String>.generate(date.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT *, (SELECT IFNULL(SUM(ml),0) FROM water_table WHERE date = wt2.date) as total FROM water_table as wt2 WHERE date IN(' +
            _sqliteVariablesForDate +
            ') GROUP BY date',
        mapper: (Map<String, Object?> row) => WaterData(id: row['id'] as int?, ml: row['ml'] as int?, date: row['date'] as String?, time: row['time'] as String?, dateTime: row['date_time'] as String?, total: row['total'] as int?),
        arguments: [...date]);
  }

  @override
  Future<WaterData?> getTotalDrinkWaterAverage(List<String> date) async {
    const offset = 1;
    final _sqliteVariablesForDate =
        Iterable<String>.generate(date.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.query(
        'SELECT *, IFNULL(SUM(ml),0) as total FROM water_table WHERE date IN(' +
            _sqliteVariablesForDate +
            ')',
        mapper: (Map<String, Object?> row) => WaterData(
            id: row['id'] as int?,
            ml: row['ml'] as int?,
            date: row['date'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            total: row['total'] as int?),
        arguments: [...date]);
  }

  @override
  Future<void> insertDrinkWater(WaterData waterData) async {
    await _waterDataInsertionAdapter.insert(
        waterData, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTodayDrinkWater(WaterData waterData) async {
    await _waterDataDeletionAdapter.delete(waterData);
  }
}

class _$WeightDao extends WeightDao {
  _$WeightDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _weightDataInsertionAdapter = InsertionAdapter(
            database,
            'weight_table',
            (WeightData item) => <String, Object?>{
                  'id': item.id,
                  'weight_kg': item.weightKg,
                  'weight_lbs': item.weightLbs,
                  'date': item.date,
                  'average': item.average
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WeightData> _weightDataInsertionAdapter;

  @override
  Future<List<WeightData>> selectAllWeight() async {
    return _queryAdapter.queryList('SELECT * FROM weight_table',
        mapper: (Map<String, Object?> row) => WeightData(
            id: row['id'] as int?,
            weightKg: row['weight_kg'] as double?,
            weightLbs: row['weight_lbs'] as double?,
            date: row['date'] as String?,
            average: row['average'] as double?));
  }

  @override
  Future<WeightData?> selectLast30DaysWeightAverage() async {
    return _queryAdapter.query(
        'SELECT AVG(weight_kg) as average FROM (SELECT * FROM weight_table ORDER BY id DESC LIMIT 30)',
        mapper: (Map<String, Object?> row) => WeightData(
            id: row['id'] as int?,
            weightKg: row['weight_kg'] as double?,
            weightLbs: row['weight_lbs'] as double?,
            date: row['date'] as String?,
            average: row['average'] as double?));
  }

  @override
  Future<void> insertWeight(WeightData task) async {
    await _weightDataInsertionAdapter.insert(task, OnConflictStrategy.replace);
  }
}

class _$StepsDao extends StepsDao {
  _$StepsDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _stepsDataInsertionAdapter = InsertionAdapter(
            database,
            'steps_table',
            (StepsData item) => <String, Object?>{
                  'id': item.id,
                  'steps': item.steps,
                  'targetSteps': item.targetSteps,
                  'stepDate': item.stepDate,
                  'time': item.time,
                  'date_time': item.dateTime,
                  'duration': item.duration,
                  'cal': item.cal,
                  'distance': item.distance
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StepsData> _stepsDataInsertionAdapter;

  @override
  Future<List<StepsData>> getAllStepsData() async {
    return _queryAdapter.queryList('SELECT * FROM steps_table',
        mapper: (Map<String, Object?> row) => StepsData(
            id: row['id'] as int?,
            steps: row['steps'] as int?,
            targetSteps: row['targetSteps'] as int?,
            stepDate: row['stepDate'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            cal: row['cal'] as int?,
            duration: row['duration'] as String?,
            distance: row['distance'] as double?));
  }

  @override
  Future<List<StepsData>> getStepsForCurrentWeekSun() async {
    return _queryAdapter.queryList(
        'SELECT * FROM steps_table WHERE (DATE(stepDate) >= DATE("now","weekday 0","-7 days"))',
        mapper: (Map<String, Object?> row) => StepsData(
            id: row['id'] as int?,
            steps: row['steps'] as int?,
            targetSteps: row['targetSteps'] as int?,
            stepDate: row['stepDate'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            cal: row['cal'] as int?,
            duration: row['duration'] as String?,
            distance: row['distance'] as double?));
  }

  @override
  Future<List<StepsData>> getStepsForCurrentWeekSat() async {
    return _queryAdapter.queryList(
        'SELECT * FROM steps_table WHERE (DATE(stepDate) >= DATE("now","weekday 6","-7 days"))',
        mapper: (Map<String, Object?> row) => StepsData(
            id: row['id'] as int?,
            steps: row['steps'] as int?,
            targetSteps: row['targetSteps'] as int?,
            stepDate: row['stepDate'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            cal: row['cal'] as int?,
            duration: row['duration'] as String?,
            distance: row['distance'] as double?));
  }

  @override
  Future<List<StepsData>> getStepsForCurrentWeekMon() async {
    return _queryAdapter.queryList(
        'SELECT * FROM steps_table WHERE (DATE(stepDate) >= DATE("now","weekday 1","-7 days"))',
        mapper: (Map<String, Object?> row) => StepsData(
            id: row['id'] as int?,
            steps: row['steps'] as int?,
            targetSteps: row['targetSteps'] as int?,
            stepDate: row['stepDate'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            cal: row['cal'] as int?,
            duration: row['duration'] as String?,
            distance: row['distance'] as double?));
  }

  @override
  Future<StepsData?> getTotalStepsForLast7Days() async {
    return _queryAdapter.query(
        'SELECT IFNULL(SUM(steps),0) as steps FROM steps_table WHERE DATE(stepDate) >= (SELECT DATE("now","-7 days"))',
        mapper: (Map<String, Object?> row) => StepsData(
            id: row['id'] as int?,
            steps: row['steps'] as int?,
            targetSteps: row['targetSteps'] as int?,
            stepDate: row['stepDate'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            cal: row['cal'] as int?,
            duration: row['duration'] as String?,
            distance: row['distance'] as double?));
  }

  @override
  Future<List<StepsData>> getStepsForCurrentMonth() async {
    return _queryAdapter.queryList(
        'SELECT * FROM steps_table WHERE (DATE(stepDate) >= DATE("now","start of month"))',
        mapper: (Map<String, Object?> row) => StepsData(
            id: row['id'] as int?,
            steps: row['steps'] as int?,
            targetSteps: row['targetSteps'] as int?,
            stepDate: row['stepDate'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            cal: row['cal'] as int?,
            duration: row['duration'] as String?,
            distance: row['distance'] as double?));
  }

  @override
  Future<StepsData?> getTotalStepsForCurrentMonth() async {
    return _queryAdapter.query(
        'SELECT IFNULL(SUM(steps),0) as steps FROM steps_table WHERE (DATE(stepDate) >= DATE("now","start of month"))',
        mapper: (Map<String, Object?> row) => StepsData(
            id: row['id'] as int?,
            steps: row['steps'] as int?,
            targetSteps: row['targetSteps'] as int?,
            stepDate: row['stepDate'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            cal: row['cal'] as int?,
            duration: row['duration'] as String?,
            distance: row['distance'] as double?));
  }

  @override
  Future<StepsData?> getTotalStepsForCurrentWeek() async {
    return _queryAdapter.query(
        'SELECT IFNULL(SUM(steps),0) as steps FROM steps_table WHERE (DATE(stepDate) >= DATE("now","weekday 1","-7 days"))',
        mapper: (Map<String, Object?> row) => StepsData(
            id: row['id'] as int?,
            steps: row['steps'] as int?,
            targetSteps: row['targetSteps'] as int?,
            stepDate: row['stepDate'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            cal: row['cal'] as int?,
            duration: row['duration'] as String?,
            distance: row['distance'] as double?));
  }

  @override
  Future<List<StepsData>> getLast7DaysStepsData() async {
    return _queryAdapter.queryList(
        'SELECT * FROM steps_table WHERE (DATE(stepDate) >= DATE("now","-7 days"))',
        mapper: (Map<String, Object?> row) => StepsData(
            id: row['id'] as int?,
            steps: row['steps'] as int?,
            targetSteps: row['targetSteps'] as int?,
            stepDate: row['stepDate'] as String?,
            time: row['time'] as String?,
            dateTime: row['date_time'] as String?,
            cal: row['cal'] as int?,
            duration: row['duration'] as String?,
            distance: row['distance'] as double?));
  }

  @override
  Future<void> insertAllStepsData(StepsData stepsData) async {
    await _stepsDataInsertionAdapter.insert(
        stepsData, OnConflictStrategy.abort);
  }
}
