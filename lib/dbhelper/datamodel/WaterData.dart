import 'package:floor/floor.dart';

@Entity(tableName: 'water_table')
class WaterData {
  @PrimaryKey(autoGenerate: true)
  @ColumnInfo(name: "id")
  final int? id;

  @ColumnInfo(name: "ml")
  final int? ml;

  @ColumnInfo(name: "date")
  final String? date;

  @ColumnInfo(name: "time")
  final String? time;

  @ColumnInfo(name: "date_time")
  final String? dateTime;

  @ColumnInfo(name: "total")
  final int? total;

  WaterData(
      {this.id,
      required this.ml,
      required this.date,
      required this.time,
      required this.dateTime,
      this.total = 0});
}
