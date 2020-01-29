import 'package:meta/meta.dart';

class Profile {
  const Profile({
    @required this.name,
    @required this.bitsId,
    @required this.room,
    @required this.qrCode,
  });

  final String name;
  final String bitsId;
  final String room;
  final String qrCode;
}
