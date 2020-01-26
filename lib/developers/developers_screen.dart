import 'package:flutter/material.dart';
import 'package:messapp/developers/developer.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/extensions.dart';
import 'package:messapp/util/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

const developers = [
  Developer(
    name: 'Pratik Bachhav',
    role: 'UX/UI Designer',
    picAsset: 'assets/images/pratik.png',
    link: Link(
      url: 'https://www.dribbble.com/pratik_bachhav',
      picAsset: 'assets/images/dribbble.png',
    ),
  ),
  Developer(
    name: 'Nishant Mahajan',
    role: 'App Developer',
    picAsset: 'assets/images/nishant.png',
    link: Link(
      url: 'https://www.github.com/AnEnigmaticBug',
      picAsset: 'assets/images/github.png',
    ),
  ),
  Developer(
    name: 'Suyash Soni',
    role: 'App Developer',
    picAsset: 'assets/images/suyash.png',
    link: Link(
      url: 'https://github.com/99suyashsoni',
      picAsset: 'assets/images/github.png',
    ),
  ),
  Developer(
    name: 'Himanshu Pandey',
    role: 'Backend Developer',
    picAsset: 'assets/images/himanshu.png',
    link: Link(
      url: 'https://www.github.com/coderjedi',
      picAsset: 'assets/images/github.png',
    ),
  ),
  Developer(
    name: 'Naman Goenka',
    role: 'Backend Developer',
    picAsset: 'assets/images/naman.png',
    link: Link(
      url: 'https://www.github.com/naman-32',
      picAsset: 'assets/images/github.png',
    ),
  ),
  Developer(
    name: 'Akshay Mittal',
    role: 'Backend Developer',
    picAsset: 'assets/images/akshay.png',
    link: Link(
      url: 'https://www.github.com/Ak-shay',
      picAsset: 'assets/images/github.png',
    ),
  ),
];

class DevelopersScreen extends StatelessWidget {
  const DevelopersScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Our Team',
      selectedTabIndex: 4,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 80.0),
        itemCount: developers.length,
        itemBuilder: (_, i) => _DeveloperTile(developer: developers[i]),
        separatorBuilder: (_, i) => SizedBox(height: 10.0),
      ),
    );
  }
}

class _DeveloperTile extends StatelessWidget {
  const _DeveloperTile({
    @required this.developer,
    Key key,
  }) : super(key: key);

  final Developer developer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(3.0, 8.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Image.asset(developer.picAsset, width: 72.0, height: 72.0),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.0),
              Text(
                developer.name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.0),
              Text(
                developer.role,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE56B44),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.0),
            ],
          ),
          Spacer(),
          GestureDetector(
            child: Image.asset(developer.link.picAsset),
            onTap: () async {
              final url = developer.link.url;

              if (!await canLaunch(url)) {
                'Could not open the link'.showSnackBar(context);
                return;
              }

              await launch(url);
            },
          ),
          SizedBox(width: 20.0),
        ],
      ),
    );
  }
}
