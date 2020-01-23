import 'package:flutter/foundation.dart';
import 'package:messapp/grubs/grub_listing.dart';
import 'package:messapp/util/date.dart';

class Offering {
  const Offering({
    @required this.id,
    @required this.name,
    @required this.items,
    @required this.price,
  });

  final int id;
  final String name;
  final List<String> items;
  final String price;
}

abstract class GrubDetails {
  const GrubDetails({
    @required this.id,
    @required this.name,
    @required this.organizer,
    @required this.date,
    @required this.offerings,
  });

  final int id;
  final String name;
  final String organizer;
  final Date date;
  final List<Offering> offerings;
}

class UnsignedGrubDetails extends GrubDetails {
  const UnsignedGrubDetails({
    @required int id,
    @required String name,
    @required String organizer,
    @required Date date,
    @required this.signUpDeadline,
    @required this.audience,
    @required List<Offering> offerings,
  }) : super(
          id: id,
          name: name,
          organizer: organizer,
          date: date,
          offerings: offerings,
        );

  final Date signUpDeadline;
  final Audience audience;
}

class SignedUpGrubDetails extends GrubDetails {
  const SignedUpGrubDetails({
    @required int id,
    @required String name,
    @required String organizer,
    @required Date date,
    @required this.cancelDeadline,
    @required this.time,
    @required this.venue,
    @required List<Offering> offerings,
    @required this.signedOfferingName,
  }) : super(
          id: id,
          name: name,
          organizer: organizer,
          date: date,
          offerings: offerings,
        );

  final Date cancelDeadline;
  final String time;
  final String venue;
  final String signedOfferingName;
}
