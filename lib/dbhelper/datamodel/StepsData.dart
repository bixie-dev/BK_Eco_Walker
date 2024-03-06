import 'package:floor/floor.dart';

@Entity(tableName: 'steps_table')
class StepsData {
  @PrimaryKey(autoGenerate: true)
  @ColumnInfo(name: "id")
  final int? id;

  @ColumnInfo(name: "steps")
  final int? steps;

  @ColumnInfo(name: "targetSteps")
  final int? targetSteps;

  @ColumnInfo(name: "stepDate")
  final String? stepDate;

  @ColumnInfo(name: "time")
  final String? time;

  @ColumnInfo(name: "date_time")
  final String? dateTime;

  @ColumnInfo(name: "duration")
  final String? duration;

  @ColumnInfo(name: "cal")
  final int? cal;

  @ColumnInfo(name: "distance")
  final double? distance;

  StepsData(
      {this.id,
      required this.steps,
      required this.targetSteps,
      required this.stepDate,
      required this.time,
      required this.dateTime,
      required this.cal,
      required this.duration,
      required this.distance});
}