import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messapp/menu/menu_info.dart';
import 'package:messapp/menu/menu_repository.dart';
import 'package:messapp/menu/menu_screen.dart';
import 'package:messapp/util/database_helper.dart';
import 'package:nice/nice.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final menuRepository = MenuRepository(
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

  final MenuRepository menuRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mess App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Quicksand',
      ),
      home: ChangeNotifierProvider.value(
        value: MenuInfo(menuRepository),
        child: MenuScreen(),
      ),
    );
  }
}
