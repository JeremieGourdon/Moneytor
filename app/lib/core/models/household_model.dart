import 'package:json_annotation/json_annotation.dart';

part 'household_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class HouseholdModel {
  final String id;
  final String name;
  final String currency;
  final int defaultMonthStartDay;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  HouseholdModel({
    required this.id,
    required this.name,
    this.currency = 'EUR',
    this.defaultMonthStartDay = 1,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) =>
      _$HouseholdModelFromJson(json);

  Map<String, dynamic> toJson() => _$HouseholdModelToJson(this);

  HouseholdModel copyWith({
    String? name,
    String? currency,
    int? defaultMonthStartDay,
  }) {
    return HouseholdModel(
      id: id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      defaultMonthStartDay: defaultMonthStartDay ?? this.defaultMonthStartDay,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt,
    );
  }
}
