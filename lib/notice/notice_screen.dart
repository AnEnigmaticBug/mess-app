import 'package:flutter/material.dart';
import 'package:messapp/notice/notice_info.dart';
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
      child: Consumer<NoticeInfo>(
        // ignore: missing_return
        builder: (_, noticeInfo, __){
          final state = noticeInfo.state;

          if(state is Loading){
            return Center(child: CircularProgressIndicator());
          }
          if(state is Failure){
            return Center(child: Text(state.error));
          }
          if(state is Success){
            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: state.notices.length,
              itemBuilder: (context, position) {
                return Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              state.notices[position].heading,
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 16.0,
                                color: AppColors.textDark
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              state.notices[position].startDate,
                              style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 12.0,
                                  color: AppColors.textDark
                              ),
                            )
                          ],
                        ),
                        Spacer(),
                        Column(
                          children: <Widget>[
                            _criticalIcon(state.notices[position].isCritical)
                          ],
                        ),
                        SizedBox(
                          width: 16.0,
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

Widget _criticalIcon(int isCritical) {
  if(isCritical == 1)
    return Text('C');
  else
    return Text('N');
}