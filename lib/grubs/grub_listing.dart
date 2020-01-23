import 'package:flutter/foundation.dart';
import 'package:messapp/util/date.dart';

enum Audience { Herbivorous, Carnivorous, Omnivorous }

class GrubListing with ChangeNotifier {
  GrubListing({
    @required this.id,
    @required this.name,
    @required this.organizer,
    @required this.date,
    @required this.signUpDeadline,
    @required this.cancelDeadline,
    @required this.audience,
    @required this.isSigned,
  });

  final int id;
  final String name;
  final String organizer;
  final Date date;
  final Date signUpDeadline;
  final Date cancelDeadline;
  final Audience audience;
  final bool isSigned;
}
