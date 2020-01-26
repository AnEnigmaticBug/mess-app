import 'package:meta/meta.dart';

class Link {
  const Link({
    @required this.url,
    @required this.picAsset,
  });

  final String url;
  final String picAsset;
}

class Developer {
  const Developer({
    @required this.name,
    @required this.role,
    @required this.picAsset,
    @required this.link,
  });

  final String name;
  final String role;
  final String picAsset;
  final Link link;
}
