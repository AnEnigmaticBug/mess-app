import 'package:meta/meta.dart';

class Contact {
  const Contact({
    @required this.name,
    @required this.post,
    @required this.photoUrl,
    @required this.mobileNo,
  });

  final String name;
  final String post;
  final String photoUrl;
  final String mobileNo;
}
