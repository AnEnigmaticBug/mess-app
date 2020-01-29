import 'package:flutter/material.dart';
import 'package:messapp/notice/notice.dart';
import 'package:messapp/notice/notice_repository.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/app_icons.dart';
import 'package:messapp/util/date.dart';
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
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 100.0),
                itemCount: state.data.length,
                itemBuilder: (_, i) => _NoticeTile(notice: state.data[i]),
                separatorBuilder: (_, __) => SizedBox(height: 12.0),
              ),
              onRefresh: () async {
                try {
                  final presenter = Provider.of<
                      SimplePresenter<NoticeRepository, List<Notice>>>(context);
                  await presenter.refresh();
                } on Exception catch (e) {
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

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    @required this.notice,
    Key key,
  }) : super(key: key);

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Heading(value: notice.heading),
                  SizedBox(height: 12.0),
                  Text(
                    _prettify(notice.startDate),
                    style: TextStyle(fontSize: 12.0, color: AppColors.textDark),
                  )
                ],
              ),
            ),
            if (notice.isCritical)
              Icon(AppIcons.star, color: AppColors.starColor),
          ],
        ),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => _NoticeBottomsheet(notice: notice),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(8.0),
            ),
          ),
        );
      },
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    @required this.value,
    Key key,
  }) : super(key: key);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
        color: AppColors.textDark,
      ),
      maxLines: 2,
    );
  }
}

class _NoticeBottomsheet extends StatelessWidget {
  const _NoticeBottomsheet({
    @required this.notice,
    Key key,
  }) : super(key: key);

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.0),
          Text(
            notice.heading,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.0),
          Text(
            _prettify(notice.startDate),
            style: TextStyle(
              fontSize: 12.0,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 30.0),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80.0),
              children: [
                Text(
                  notice.body,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.0,
                    height: 1.5,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _prettify(Date date) {
  return '${DateFormatter(date).month} ${date.day}';
}
