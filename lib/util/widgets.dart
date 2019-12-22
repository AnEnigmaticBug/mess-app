import 'package:flutter/material.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/app_icons.dart';

class Screen extends StatelessWidget {
  const Screen({
    @required this.title,
    @required this.child,
    @required this.selectedTabIndex,
    Key key,
  }) : super(key: key);

  final String title;
  final Widget child;
  final int selectedTabIndex;

  @override
  Widget build(BuildContext context) {
    final appBarStyle = Theme.of(context).textTheme.title;
    return Scaffold(
      appBar: AppBar(title: Text(title, style: appBarStyle), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundGradient1,
              AppColors.backgroundGradient2,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: child,
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: selectedTabIndex,
      ),
    );
  }
}

class TabbedScreen extends StatelessWidget {
  const TabbedScreen({
    @required this.title,
    @required this.tabs,
    @required this.children,
    @required this.selectedTabIndex,
    this.fab,
    Key key,
  })  : assert(tabs.length == children.length),
        super(key: key);

  final String title;
  final List<String> tabs;
  final List<Widget> children;
  final int selectedTabIndex;
  final Widget fab;

  @override
  Widget build(BuildContext context) {
    final appBarStyle = Theme.of(context).textTheme.title;
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: appBarStyle),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.textDark,
            labelStyle: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              fontFamily: 'Quicksand',
            ),
            indicatorColor: AppColors.textDark,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: tabs
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(t),
                  ),
                )
                .toList(),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.backgroundGradient1,
                AppColors.backgroundGradient2,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: TabBarView(children: children),
          ),
        ),
        floatingActionButton: fab,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: _BottomNav(
          currentIndex: selectedTabIndex,
        ),
      ),
    );
  }
}

class FAB extends StatelessWidget {
  const FAB({
    @required this.label,
    @required this.onPressed,
    Key key,
  }) : super(key: key);

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(offset: Offset(0.0, 6.0), blurRadius: 6.0, color: Color(0x1A000000)),
        ],
      ),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        color: Color(0xFFFFE0A4),
        child: Text(label),
        textColor: AppColors.textDark,
        onPressed: onPressed,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    this.currentIndex,
    Key key,
  }) : super(key: key);

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: AppColors.bottomNavBackground,
      selectedItemColor: AppColors.bottomNavSelected,
      unselectedItemColor: AppColors.bottomNavUnselected,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 9.0,
      unselectedFontSize: 9.0,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      items: [
        _bottomNavItem(
          title: 'Profile',
          selectedIconData: AppIcons.profile_outlined,
          unselectedIconData: AppIcons.profile_solid,
          isSelected: currentIndex == 0,
        ),
        _bottomNavItem(
          title: 'Grubs',
          selectedIconData: AppIcons.grubs_outlined,
          unselectedIconData: AppIcons.grubs_solid,
          isSelected: currentIndex == 1,
        ),
        _bottomNavItem(
          title: 'Menu',
          selectedIconData: AppIcons.menu_outlined,
          unselectedIconData: AppIcons.menu_solid,
          isSelected: currentIndex == 2,
        ),
        _bottomNavItem(
          title: 'Feedback',
          selectedIconData: AppIcons.feedback_outlined,
          unselectedIconData: AppIcons.feedback_solid,
          isSelected: currentIndex == 3,
        ),
        _bottomNavItem(
          title: 'More',
          selectedIconData: AppIcons.more_outlined,
          unselectedIconData: AppIcons.more_solid,
          isSelected: currentIndex == 4,
        ),
      ],
    );
  }
}

BottomNavigationBarItem _bottomNavItem({
  String title,
  IconData selectedIconData,
  IconData unselectedIconData,
  bool isSelected,
}) {
  return BottomNavigationBarItem(
    title: Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(title),
    ),
    icon: Icon(isSelected ? selectedIconData : unselectedIconData),
  );
}
