import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:messapp/profile/profile.dart';
import 'package:messapp/profile/profile_presenter.dart';
import 'package:messapp/profile/profile_repository.dart';
import 'package:messapp/profile/profile_screen.dart';
import 'package:messapp/util/app_theme_data.dart';
import 'package:messapp/util/database_helper.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:messapp/util/simple_presenter.dart';
import 'package:messapp/util/time_keeper.dart';
import 'package:nice/nice.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

////    http://142.93.213.45/api
//    baseUrl: 'http://ssmsbitspilani.pythonanywhere.com/api',

  Crashlytics.instance.enableInDevMode = false;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZoned(() async {
    final db = await databaseInstance('revamp.db');
    final prefs = await SharedPreferences.getInstance();
    final client = NiceClient(
      baseUrl: 'http://ssmsbitspilani.pythonanywhere.com/api',
      headers: {'Content-Type': 'application/json'},
    );
    final keeper = TimeKeeper(
      durations: {
        PrefKeys.contactsRefresh: Duration(days: 30),
        PrefKeys.grubsRefresh: Duration(days: 3),
        PrefKeys.issuesRefresh: Duration(days: 1),
        PrefKeys.noticesRefresh: Duration(days: 2),
        PrefKeys.ratingsPush: Duration(days: 5),
      },
      preferences: prefs,
    );
    final analytics = FirebaseAnalytics();
    final messaging = FirebaseMessaging();

    await messaging.requestNotificationPermissions(IosNotificationSettings());

    final loginRepository = LoginRepository(
      preferences: prefs,
      client: client,
      messaging: messaging,
    );
    final profileRepository =
        ProfileRepository(preferences: prefs, client: client);
    final grubRepository = GrubRepository(
      database: db,
      client: client,
      keeper: keeper,
    );
    final menuRepository = MenuRepository(
      database: db,
      client: client,
      keeper: keeper,
    );
    final issueRepository = IssueRepository(
      database: db,
      client: client,
      keeper: keeper,
    );
    final noticeRepository = NoticeRepository(
      database: db,
      client: client,
      keeper: keeper,
    );
    final contactRepository = ContactRepository(
      database: db,
      client: client,
      keeper: keeper,
    );

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
        analytics: analytics,
        loginRepository: loginRepository,
        grubRepository: grubRepository,
        menuRepository: menuRepository,
        issueRepository: issueRepository,
        noticeRepository: noticeRepository,
        contactRepository: contactRepository,
        profileRepository: profileRepository,
      ));
    } else {
      runApp(MessApp(
        initialRoute: '/login',
        analytics: analytics,
        loginRepository: loginRepository,
        grubRepository: grubRepository,
        menuRepository: menuRepository,
        issueRepository: issueRepository,
        noticeRepository: noticeRepository,
        contactRepository: contactRepository,
        profileRepository: profileRepository,
      ));
    }
  }, onError: Crashlytics.instance.recordError);
}

class MessApp extends StatelessWidget {
  const MessApp({
    @required this.initialRoute,
    @required this.analytics,
    @required this.loginRepository,
    @required this.grubRepository,
    @required this.menuRepository,
    @required this.issueRepository,
    @required this.noticeRepository,
    @required this.contactRepository,
    @required this.profileRepository,
    Key key,
  }) : super(key: key);

  final String initialRoute;
  final FirebaseAnalytics analytics;
  final LoginRepository loginRepository;
  final GrubRepository grubRepository;
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
        '/profile': (context) {
          return ChangeNotifierProvider.value(
            value: ProfilePresenter(profileRepository),
            child: ProfileScreen(),
          );
        }
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
