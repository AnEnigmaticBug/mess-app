import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messapp/menu/menu_info.dart';
import 'package:messapp/menu/menu_repository.dart';
import 'package:messapp/menu/menu_screen.dart';
import 'package:messapp/notice/notice_info.dart';
import 'package:messapp/notice/notice_repository.dart';
import 'package:messapp/notice/notice_screen.dart';
import 'package:messapp/util/app_theme_data.dart';
import 'package:messapp/util/database_helper.dart';
import 'package:nice/nice.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final menuRepository = NoticeRepository(
    database: await databaseInstance('revamp.db'),
    client: NiceClient(
      baseUrl: 'http://142.93.213.45/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5A534A),
    ),
  );

  runApp(MessApp(menuRepository: menuRepository));
}

class MessApp extends StatelessWidget {
  const MessApp({
    @required this.menuRepository,
    Key key,
  }) : super(key: key);

  final NoticeRepository menuRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mess App',
      theme: appThemeData,
      home: ChangeNotifierProvider.value(
        value: NoticeInfo(menuRepository),
        child: NoticeScreen(),
      ),
    );
  }
}
