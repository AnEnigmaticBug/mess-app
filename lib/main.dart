import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messapp/about/about_screen.dart';
import 'package:messapp/contacts/contact.dart';
import 'package:messapp/contacts/contact_repository.dart';
import 'package:messapp/contacts/contacts_screen.dart';
import 'package:messapp/issues/create_issue_screen.dart';
import 'package:messapp/issues/issue.dart';
import 'package:messapp/issues/issue_repository.dart';
import 'package:messapp/issues/issues_screen.dart';
import 'package:messapp/login/login_repository.dart';
import 'package:messapp/login/login_screen.dart';
import 'package:messapp/menu/menu.dart';
import 'package:messapp/menu/menu_repository.dart';
import 'package:messapp/menu/menu_screen.dart';
import 'package:messapp/more/more_screen.dart';
import 'package:messapp/notice/notice.dart';
import 'package:messapp/notice/notice_repository.dart';
import 'package:messapp/notice/notice_screen.dart';
import 'package:messapp/profile/profile.dart';
import 'package:messapp/profile/profile_repository.dart';
import 'package:messapp/profile/profile_screen.dart';
import 'package:messapp/util/app_theme_data.dart';
import 'package:messapp/util/database_helper.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:messapp/util/simple_presenter.dart';
import 'package:nice/nice.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await databaseInstance('revamp.db');
  final prefs = await SharedPreferences.getInstance();
  final client = NiceClient(
    baseUrl: 'http://142.93.213.45/api',
    headers: {'Content-Type': 'application/json'},
  );

  final loginRepository = LoginRepository(preferences: prefs, client: client);
  final menuRepository = MenuRepository(database: db, client: client);
  final issueRepository = IssueRepository(database: db, client: client);
  final noticeRepository = NoticeRepository(database: db, client: client);
  final contactRepository = ContactRepository(database: db, client: client);
  final profileRepository = ProfileRepository(preferences: prefs);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5A534A),
    ),
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (prefs.containsKey(PrefKeys.jwt)) {
    client.headers.addAll({'Authorization': prefs.getString(PrefKeys.jwt)});

    runApp(MessApp(
      initialRoute: '/',
      loginRepository: loginRepository,
      menuRepository: menuRepository,
      issueRepository: issueRepository,
      noticeRepository: noticeRepository,
      contactRepository: contactRepository,
    ));
  } else {
    runApp(MessApp(
      initialRoute: '/login',
      loginRepository: loginRepository,
      menuRepository: menuRepository,
      issueRepository: issueRepository,
      noticeRepository: noticeRepository,
      contactRepository: contactRepository,
      profileRepository: profileRepository,
    ));
  }
}

class MessApp extends StatelessWidget {
  const MessApp({
    @required this.initialRoute,
    @required this.loginRepository,
    @required this.menuRepository,
    @required this.issueRepository,
    @required this.noticeRepository,
    @required this.contactRepository,
    @required this.profileRepository,
    Key key,
  }) : super(key: key);

  final String initialRoute;
  final LoginRepository loginRepository;
  final MenuRepository menuRepository;
  final IssueRepository issueRepository;
  final NoticeRepository noticeRepository;
  final ContactRepository contactRepository;
  final ProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mess App',
      theme: appThemeData,
      initialRoute: initialRoute,
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
            value: SimplePresenter<IssueRepository, Data>(
                repository: issueRepository,
                mapper: (repo) async {
                  final active = await repo.activeIssues;
                  final solved = await repo.solvedIssues;
                  solved.sort((a, b) => -a.dateSolved.compareTo(b.dateSolved));
                  final recent = List<ActiveIssue>.from(active);
                  recent
                      .sort((a, b) => -a.dateCreated.compareTo(b.dateCreated));
                  final popular = List<ActiveIssue>.from(active);
                  popular
                      .sort((a, b) => -a.upvoteCount.compareTo(b.upvoteCount));

                  return Data(
                    recentIssues: recent,
                    popularIssues: popular,
                    solvedIssues: solved,
                  );
                }),
            child: IssuesScreen(),
          );
        },
        '/login': (context) {
          return Provider.value(
            value: loginRepository,
            child: LoginScreen(),
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
        '/profile': (context) {
          return ChangeNotifierProvider.value(

          );
        }
      },
    );
  }
}
