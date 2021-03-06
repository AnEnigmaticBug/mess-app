import 'package:flutter/foundation.dart';
import 'package:messapp/util/date.dart';

class Notice {
  const Notice({
    @required this.id,
    @required this.body,
    @required this.heading,
    @required this.startDate,
    @required this.isCritical,
  });

  final int id;
  final String heading;
  final String body;
  final Date startDate;
  final bool isCritical;
}
