import 'package:flutter/material.dart';
import 'package:messapp/notice/notice.dart';
import 'package:messapp/notice/notice_repository.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/app_icons.dart';
import 'package:messapp/util/simple_presenter.dart';
import 'package:messapp/util/ui_state.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:messapp/util/extensions.dart';

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
            if (state.data.isEmpty) {
              return IllustratedMessage(
                illustration: Image.asset('assets/images/empty_notice.png'),
                message: 'It\'s deserted here, come back later',
                onRetry: presenter.restart,
              );
            }

            return RefreshIndicator(
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: state.data.length,
                itemBuilder: (context, position) {
                  return GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
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
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                state.data[position].heading,
                                style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                    color: AppColors.textDark),
                                maxLines: 2,
                              ),
                              SizedBox(
                                height: 12.0,
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
                            width: 8.0,
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  state.data[position].heading,
                                  style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16.0,
                                      color: AppColors.textDark),
                                ),
                                Text(
                                  state.data[position].startDate,
                                  style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontSize: 12.0,
                                      color: AppColors.textDark),
                                ),
                                Text(
                                  state.data[position].body,
                                  style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontSize: 12.0,
                                      color: AppColors.textDark),
                                  ),
                                )
                              ],
                            ),
                          ));
                    },
                  );
                },
              ),
              onRefresh: () async {
                try{
                  final presenter = Provider.of<SimplePresenter<NoticeRepository, List<Notice>>>(context);
                  await presenter.refresh();
                }on Exception catch (e) {
                  e.toString().showSnackBar(context);
                }
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
