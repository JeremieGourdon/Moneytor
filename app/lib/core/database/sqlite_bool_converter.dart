import 'package:json_annotation/json_annotation.dart';

class SQLiteBoolConverter implements JsonConverter<bool, dynamic> {
  const SQLiteBoolConverter();

  @override
  bool fromJson(dynamic json) {
    if (json is bool) return json;
    if (json is int) return json == 1;
    if (json is String) return json == '1' || json.toLowerCase() == 'true';
    return false;
  }

  @override
  dynamic toJson(bool object) => object ? 1 : 0;
}
