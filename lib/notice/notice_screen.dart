import 'package:flutter/material.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/app_icons.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';

class NoticeScreen extends StatelessWidget{

  const NoticeScreen({
    Key key,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Notice',
      selectedTabIndex: 4,
    );
  }
}