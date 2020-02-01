import 'package:flutter/material.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/app_icons.dart';
import 'package:messapp/util/widgets.dart';

class MoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'More',
      selectedTabIndex: 4,
      isTopLevel: true,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 80.0),
            children: [
              _MoreTile(
                name: 'Notices',
                icon: AppIcons.notices,
                routeName: '/notices',
              ),
              SizedBox(height: 16.0),
              _MoreTile(
                name: 'SSMS GC Members',
                icon: AppIcons.contacts,
                routeName: '/contacts',
              ),
              SizedBox(height: 16.0),
              _MoreTile(
                name: 'Our Team',
                icon: AppIcons.developers,
                routeName: '/developers',
              ),
              SizedBox(height: 16.0),
              _MoreTile(
                name: 'About SSMS',
                icon: AppIcons.about,
                routeName: '/about',
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '🔥 Hand-baked by the SSMS Tech Team! 🔥',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    @required this.name,
    @required this.icon,
    @required this.routeName,
    Key key,
  }) : super(key: key);

  final String name;
  final IconData icon;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              offset: Offset(3.0, 6.0),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 16.0),
            Text(
              name,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            Spacer(),
            _MoreIcon(icon: icon),
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}

class _MoreIcon extends StatelessWidget {
  const _MoreIcon({
    Key key,
    @required this.icon,
  }) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28.0, 20.0, 24.0, 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(8.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x6EDD5435),
            offset: Offset(0.0, 8.0),
            blurRadius: 10.0,
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Color(0xFFF49B65),
            Color(0xFFD9492D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(icon, size: 30.0, color: Color(0xFFFBE2D6)),
    );
  }
}
