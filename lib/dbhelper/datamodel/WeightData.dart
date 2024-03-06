import 'package:floor/floor.dart';

@Entity(tableName: "weight_table",indices: [
  Index(value: ['date'], unique: true)
],)
class WeightData {
  @PrimaryKey(autoGenerate: true)
  @ColumnInfo(name: 'id')
  final int? id;

  @ColumnInfo(name: 'weight_kg')
  final double? weightKg;

  @ColumnInfo(name: 'weight_lbs')
  final double? weightLbs;

  @ColumnInfo(name: 'date')
  final String? date;

  @ColumnInfo(name: "average")
  final double? average;

  WeightData(
      {this.id,
      required this.weightKg,
      required this.weightLbs,
      required this.date,this.average = 0.0});
}
