import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messapp/about/about_screen.dart';
import 'package:messapp/contacts/contact.dart';
import 'package:messapp/contacts/contact_repository.dart';
import 'package:messapp/contacts/contacts_screen.dart';
import 'package:messapp/issues/create_issue_screen.dart';
import 'package:messapp/issues/issue_info.dart';
import 'package:messapp/issues/issue_repository.dart';
import 'package:messapp/issues/issues_screen.dart';
import 'package:messapp/menu/menu.dart';
import 'package:messapp/menu/menu_repository.dart';
import 'package:messapp/menu/menu_screen.dart';
import 'package:messapp/more/more_screen.dart';
import 'package:messapp/notice/notice.dart';
import 'package:messapp/notice/notice_repository.dart';
import 'package:messapp/notice/notice_screen.dart';
import 'package:messapp/util/app_theme_data.dart';
import 'package:messapp/util/database_helper.dart';
import 'package:messapp/util/simple_presenter.dart';
import 'package:nice/nice.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await databaseInstance('revamp.db');
  final client = NiceClient(
    baseUrl: 'http://142.93.213.45/api',
    headers: {'Content-Type': 'application/json'},
  );

  final menuRepository = MenuRepository(database: db, client: client);
  final issueRepository = IssueRepository(database: db, client: client);
  final noticeRepository = NoticeRepository(database: db, client: client);
  final contactRepository = ContactRepository(database: db, client: client);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5A534A),
    ),
  );

  runApp(MessApp(
    menuRepository: menuRepository,
    issueRepository: issueRepository,
    noticeRepository: noticeRepository,
    contactRepository: contactRepository,
  ));
}

class MessApp extends StatelessWidget {
  const MessApp({
    @required this.menuRepository,
    @required this.issueRepository,
    @required this.noticeRepository,
    @required this.contactRepository,
    Key key,
  }) : super(key: key);

  final MenuRepository menuRepository;
  final IssueRepository issueRepository;
  final NoticeRepository noticeRepository;
  final ContactRepository contactRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mess App',
      theme: appThemeData,
      routes: {
        '/': (context) {
          return ChangeNotifierProvider.value(
            value: SimplePresenter<MenuRepository, List<Menu>>(
              repository: menuRepository,
              mapper: (repo) => repo.menus,
            ),
            child: MenuScreen(),
          );
        },
        '/about': (context) {
          return AboutScreen();
        },
        '/contacts': (context) {
          return ChangeNotifierProvider.value(
            value: SimplePresenter<ContactRepository, List<Contact>>(
              repository: contactRepository,
              mapper: (repo) => repo.contacts,
            ),
            child: ContactsScreen(),
          );
        },
        '/create-issue': (context) {
          return Provider.value(
            value: issueRepository,
            child: CreateIssueScreen(),
          );
        },
        '/issues': (context) {
          return ChangeNotifierProvider.value(
            value: IssueInfo(issueRepository),
            child: IssuesScreen(),
          );
        },
        '/more': (context) {
          return MoreScreen();
        },
        '/notices': (context) {
          return ChangeNotifierProvider.value(
            value: SimplePresenter<NoticeRepository, List<Notice>>(
              repository: noticeRepository,
              mapper: (repo) => repo.notices,
            ),
            child: NoticeScreen(),
          );
        },
      },
    );
  }
}
