import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messapp/issues/issue.dart';
import 'package:messapp/issues/issue_repository.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/app_icons.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/extensions.dart';
import 'package:messapp/util/simple_presenter.dart';
import 'package:messapp/util/ui_state.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';

class Data {
  const Data({
    @required this.recentIssues,
    @required this.popularIssues,
    @required this.solvedIssues,
  });

  final List<Issue> recentIssues;
  final List<Issue> popularIssues;
  final List<Issue> solvedIssues;
}

class IssuesScreen extends StatelessWidget {
  const IssuesScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SimplePresenter<IssueRepository, Data>>(
      builder: (_, presenter, __) {
        final state = presenter.state;

        if (state is Loading) {
          return Screen(
            title: 'Issues',
            selectedTabIndex: 3,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is Success) {
          return TabbedScreen(
            title: 'Issues',
            selectedTabIndex: 3,
            tabs: ['Recent', 'Popular', 'Solved'],
            children: [
              _IssueTab<ActiveIssue>(state.data.recentIssues),
              _IssueTab<ActiveIssue>(state.data.popularIssues),
              _IssueTab<SolvedIssue>(state.data.solvedIssues),
            ],
            fab: Builder(
              builder: (context) {
                // Builder allows us to use Scaffold.
                return FAB(
                  label: '+ Create new issue',
                  onPressed: () async {
                    try {
                      final wasSuccessful =
                          await Navigator.pushNamed(context, '/create-issue');
                      if (wasSuccessful != null && wasSuccessful) {
                        'Issue created successfully'.showSnackBar(context);
                      }
                      await presenter.restart();
                    } on Exception {
                      'Please refresh the issues data'.showSnackBar(context);
                    }
                  },
                );
              },
            ),
          );
        }

        if (state is Failure) {
          return Screen(
            title: 'Issues',
            selectedTabIndex: 3,
            child: ErrorMessage(
              message: state.message,
              onRetry: presenter.restart,
            ),
          );
        }
      },
    );
  }
}

class _IssueTab<T extends Issue> extends StatelessWidget {
  const _IssueTab(
    this.issues, {
    Key key,
  }) : super(key: key);

  final List<T> issues;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 100.0),
        itemCount: issues.length,
        itemBuilder: (_, i) {
          if (issues[i] is ActiveIssue) {
            return ChangeNotifierProvider.value(
              value: issues[i] as ActiveIssue,
              child: _ActiveTile(),
            );
          }
          if (issues[i] is SolvedIssue) {
            return ChangeNotifierProvider.value(
              value: issues[i] as SolvedIssue,
              child: _SolvedTile(),
            );
          }
        },
        separatorBuilder: (_, __) => SizedBox(height: 12.0),
      ),
      onRefresh: () async {
        try {
          final presenter =
              Provider.of<SimplePresenter<IssueRepository, Data>>(context);
          await presenter.refresh();
        } on Exception catch (e) {
          e.toString().showSnackBar(context);
        }
      },
    );
  }
}

class _ActiveTile extends StatelessWidget {
  const _ActiveTile({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final issue = Provider.of<ActiveIssue>(context);
    return Container(
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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    issue.title,
                    style: TextStyle(color: AppColors.textDark),
                    maxLines: 2,
                  ),
                ),
              ),
              _FlagButton(),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: [
              _UpvoteButton(issue: issue),
              Spacer(),
              _DateOldness(date: issue.dateCreated, color: AppColors.mildDark),
              SizedBox(width: 16.0),
            ],
          ),
        ],
      ),
    );
  }
}

class _SolvedTile extends StatefulWidget {
  @override
  _SolvedTileState createState() => _SolvedTileState();
}

class _SolvedTileState extends State<_SolvedTile> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(3.0, 8.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: AnimatedCrossFade(
          firstChild: _SolvedTileClosed(
            onOpenPressed: () {
              setState(() {
                isOpen = true;
              });
            },
          ),
          secondChild: _SolvedTileOpened(
            onHidePressed: () {
              setState(() {
                isOpen = false;
              });
            },
          ),
          crossFadeState:
              isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 200),
        ),
      ),
    );
  }
}

class _SolvedTileClosed extends StatelessWidget {
  const _SolvedTileClosed({
    @required this.onOpenPressed,
    Key key,
  }) : super(key: key);

  final VoidCallback onOpenPressed;

  @override
  Widget build(BuildContext context) {
    final issue = Provider.of<SolvedIssue>(context);
    return _SolvedTileHeader(
      issue: issue,
      toggleMessage: 'Tap for details',
      onToggled: onOpenPressed,
    );
  }
}

class _SolvedTileOpened extends StatelessWidget {
  const _SolvedTileOpened({
    @required this.onHidePressed,
    Key key,
  }) : super(key: key);

  final VoidCallback onHidePressed;

  @override
  Widget build(BuildContext context) {
    final issue = Provider.of<SolvedIssue>(context);
    return Column(
      children: [
        _SolvedTileHeader(
          issue: issue,
          toggleMessage: 'Hide details',
          onToggled: onHidePressed,
        ),
        _SolvedTileFooter(issue: issue),
      ],
    );
  }
}

class _SolvedTileHeader extends StatelessWidget {
  const _SolvedTileHeader({
    Key key,
    @required this.issue,
    @required this.toggleMessage,
    @required this.onToggled,
  }) : super(key: key);

  final SolvedIssue issue;
  final String toggleMessage;
  final onToggled;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0, right: 16.0),
                  child: Text(
                    issue.title,
                    style: TextStyle(color: AppColors.textDark),
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              _UpvoteCount(count: issue.upvoteCount),
              Spacer(),
              _UnderlinedButton(
                message: toggleMessage,
                onPressed: onToggled,
              ),
            ],
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

class _SolvedTileFooter extends StatelessWidget {
  const _SolvedTileFooter({
    Key key,
    @required this.issue,
  }) : super(key: key);

  final SolvedIssue issue;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mildDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Text(
              issue.reason,
              style: TextStyle(color: Colors.white),
              maxLines: 2,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _DateOldness(date: issue.dateSolved, color: Colors.white),
              SizedBox(width: 16.0),
            ],
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class _DateOldness extends StatelessWidget {
  const _DateOldness({
    @required this.date,
    @required this.color,
    Key key,
  }) : super(key: key);

  final Date date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(AppIcons.clock, color: color, size: 12.0),
        SizedBox(width: 2.0),
        Text(
          DateFormatter(date).oldness,
          style: TextStyle(fontSize: 10.0, color: color),
        ),
      ],
    );
  }
}

class _FlagButton extends StatelessWidget {
  const _FlagButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final issue = Provider.of<ActiveIssue>(context);
    return IconButton(
      icon: Icon(
        issue.flagged ? AppIcons.flag_solid : AppIcons.flag_outlined,
        color: issue.flagged ? Color(0xFFDB4F31) : AppColors.mildDark,
        size: 16.0,
      ),
      onPressed: () async {
        try {
          await issue.setFlagged(!issue.flagged);
        } on Exception {
          'Could not flag the issue'.showSnackBar(context);
        }
      },
    );
  }
}

class _UpvoteButton extends StatelessWidget {
  const _UpvoteButton({
    @required this.issue,
    Key key,
  }) : super(key: key);

  final ActiveIssue issue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mildDark),
        borderRadius: BorderRadius.circular(8.0),
        color: issue.upvoted ? AppColors.mildDark : Colors.transparent,
      ),
      child: InkWell(
        child: SizedBox(
          width: 48.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(width: 4.0),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Icon(
                  issue.upvoted
                      ? AppIcons.upvote_solid
                      : AppIcons.upvote_outlined,
                  color: textColor(issue.upvoted),
                  size: 12.0,
                ),
              ),
              Spacer(flex: 1),
              Text(
                issue.upvoteCount.toString(),
                style: TextStyle(
                  fontSize: 11.0,
                  color: textColor(issue.upvoted),
                ),
              ),
              Spacer(flex: 5),
            ],
          ),
        ),
        onTap: () async {
          try {
            await issue.setUpvoted(!issue.upvoted);
          } on Exception {
            'Could not modify upvotes'.showSnackBar(context);
          }
        },
      ),
    );
  }

  Color textColor(bool upvoted) => upvoted ? Colors.white : AppColors.mildDark;
}

class _UpvoteCount extends StatelessWidget {
  const _UpvoteCount({
    this.count,
    Key key,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: SizedBox(
        width: 48.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Icon(
              AppIcons.upvote_solid,
              color: AppColors.mildDark,
              size: 12.0,
            ),
            SizedBox(width: 4.0),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11.0,
                color: AppColors.mildDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnderlinedButton extends StatelessWidget {
  const _UnderlinedButton({
    @required this.message,
    @required this.onPressed,
    Key key,
  }) : super(key: key);

  final String message;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 9.0,
          color: AppColors.mildDark,
          decoration: TextDecoration.underline,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: onPressed,
    );
  }
}
