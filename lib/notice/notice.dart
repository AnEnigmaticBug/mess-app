import 'package:flutter/foundation.dart';

class Notice{

  const Notice({
    @required this.id,
    @required this.body,
    @required this.heading,
    @required this.startDate,
    @required this.endDate,
    @required this.noticeType
  });

  final int id;
  final String heading;
  final String body;
  final String startDate;
  final String endDate;
  final String noticeType;
}