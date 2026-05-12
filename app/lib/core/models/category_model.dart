import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CategoryModel {
  final String id;
  final String householdId;
  final String name;
  final String? icon;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  CategoryModel({
    required this.id,
    required this.householdId,
    required this.name,
    this.icon,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
