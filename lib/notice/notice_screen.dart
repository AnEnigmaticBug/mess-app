import 'package:flutter/material.dart';
import 'package:messapp/notice/notice.dart';
import 'package:messapp/notice/notice_repository.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/app_icons.dart';
import 'package:messapp/util/simple_presenter.dart';
import 'package:messapp/util/ui_state.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Notice',
      selectedTabIndex: 4,
      child: Consumer<SimplePresenter<NoticeRepository, List<Notice>>>(
        // ignore: missing_return
        builder: (_, presenter, __) {
          final state = presenter.state;

          if (state is Loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is Success) {
            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: state.data.length,
              itemBuilder: (context, position) {
                return Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              state.data[position].heading,
                              style: TextStyle(
                                  fontFamily: 'Quicksand-SemiBold',
                                  fontSize: 16.0,
                                  color: AppColors.textDark),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              state.data[position].startDate,
                              style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 12.0,
                                  color: AppColors.textDark),
                            )
                          ],
                        ),
                        Spacer(),
                        Column(
                          children: <Widget>[
                            _criticalIcon(state.data[position].isCritical)
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

          if (state is Failure) {
            return ErrorMessage(
              message: state.message,
              onRetry: presenter.restart,
            );
          }
        },
      ),
    );
  }
}

Widget _criticalIcon(int isCritical) {
  if (isCritical == 1)
    return Icon(
      AppIcons.star,
      color: AppColors.starColor,
    );
  else
    return SizedBox(width: 1.0, height: 1.0);
}
