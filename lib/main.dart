import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messapp/about/about_screen.dart';
import 'package:messapp/contacts/contact.dart';
import 'package:messapp/contacts/contact_repository.dart';
import 'package:messapp/contacts/contacts_screen.dart';
import 'package:messapp/developers/developers_screen.dart';
import 'package:messapp/grubs/grub_details_presenter.dart';
import 'package:messapp/grubs/grub_details_screen.dart';
import 'package:messapp/grubs/grub_repository.dart';
import 'package:messapp/grubs/grubs_screen.dart' as g;
import 'package:messapp/issues/create_issue_screen.dart';
import 'package:messapp/issues/issue.dart';
import 'package:messapp/issues/issue_repository.dart';
import 'package:messapp/issues/issues_screen.dart' as i;
import 'package:messapp/login/login_repository.dart';
import 'package:messapp/login/login_screen.dart';
import 'package:messapp/menu/menu.dart';
import 'package:messapp/menu/menu_repository.dart';
import 'package:messapp/menu/menu_screen.dart';
import 'package:messapp/more/more_screen.dart';
import 'package:messapp/notice/notice.dart';
import 'package:messapp/notice/notice_repository.dart';
import 'package:messapp/notice/notice_screen.dart';
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

  final loginrepository = LoginRepository(preferences: prefs, client: client);
  final grubRepository = GrubRepository(database: db, client: client);
  final menuRepository = MenuRepository(database: db, client: client);
  final issueRepository = IssueRepository(database: db, client: client);
  final noticeRepository = NoticeRepository(database: db, client: client);
  final contactRepository = ContactRepository(database: db, client: client);

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
      loginRepository: loginrepository,
      grubRepository: grubRepository,
      menuRepository: menuRepository,
      issueRepository: issueRepository,
      noticeRepository: noticeRepository,
      contactRepository: contactRepository,
    ));
  } else {
    runApp(MessApp(
      initialRoute: '/login',
      loginRepository: loginrepository,
      grubRepository: grubRepository,
      menuRepository: menuRepository,
      issueRepository: issueRepository,
      noticeRepository: noticeRepository,
      contactRepository: contactRepository,
    ));
  }
}

class MessApp extends StatelessWidget {
  const MessApp({
    @required this.initialRoute,
    @required this.loginRepository,
    @required this.grubRepository,
    @required this.menuRepository,
    @required this.issueRepository,
    @required this.noticeRepository,
    @required this.contactRepository,
    Key key,
  }) : super(key: key);

  final String initialRoute;
  final LoginRepository loginRepository;
  final GrubRepository grubRepository;
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
        '/developers': (context) {
          return DevelopersScreen();
        },
        '/grubs': (context) {
          return ChangeNotifierProvider.value(
            value: SimplePresenter<GrubRepository, g.Data>(
              repository: grubRepository,
              mapper: (repo) async {
                final upcoming = await repo.grubListings;
                upcoming.sort((a, b) => -a.date.compareTo(b.date));
                final signedUp = upcoming.where((l) => l.isSigned).toList();
                signedUp.sort((a, b) => -a.date.compareTo(b.date));

                return g.Data(
                  upcomingGrubs: upcoming,
                  signedUpGrubs: signedUp,
                );
              },
            ),
            child: g.GrubsScreen(),
          );
        },
        '/grub-details': (context) {
          final args =
              ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
          return ChangeNotifierProvider.value(
            value: GrubDetailsPresenter(
              repository: grubRepository,
              grubId: args['id'],
            ),
            child: GrubDetailsScreen(grubName: args['name']),
          );
        },
        '/issues': (context) {
          return ChangeNotifierProvider.value(
            value: SimplePresenter<IssueRepository, i.Data>(
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

                  return i.Data(
                    recentIssues: recent,
                    popularIssues: popular,
                    solvedIssues: solved,
                  );
                }),
            child: i.IssuesScreen(),
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
      },
    );
  }
}
