import 'package:json_server/Models/fosc.dart';

class ResponseModel {
  final int totalRows;
  final List<Fosc> rows;

  ResponseModel(this.totalRows, this.rows);

  Map<String, dynamic> toJson() {
    return {
      'totalRows': totalRows,
      'rows': rows.map((e) => e.toJson()).toList()
    };
  }
}