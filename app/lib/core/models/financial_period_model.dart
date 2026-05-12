import 'package:json_annotation/json_annotation.dart';

part 'financial_period_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FinancialPeriodModel {
  final String id;
  final String householdId;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialPeriodModel({
    required this.id,
    required this.householdId,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialPeriodModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialPeriodModelFromJson(json);

  Map<String, dynamic> toJson() => _$FinancialPeriodModelToJson(this);

  FinancialPeriodModel copyWith({
    String? name,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return FinancialPeriodModel(
      id: id,
      householdId: householdId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
